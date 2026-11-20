import re
from datetime import UTC, datetime, timedelta

from sqlalchemy.dialects import postgresql

from app.models import AnalyticsAppearance, AnalyticsCount, AnalyticsJourney
from app.modules.analytics import retention

NOW = datetime(2026, 11, 20, 5, 0, tzinfo=UTC)
CASTS = re.compile(r"::(?:TIMESTAMP WITH TIME ZONE|INTEGER|BIGINT)")


def sql(statement) -> str:
    return " ".join(CASTS.sub("", str(statement.compile(dialect=postgresql.dialect()))).split())


class Result:
    def __init__(self, rowcount):
        self.rowcount = rowcount


class FakeSession:
    def __init__(self, rowcounts):
        self.rowcounts = list(rowcounts)
        self.statements = []
        self.commits = 0

    async def execute(self, statement):
        self.statements.append(statement)
        return Result(self.rowcounts.pop(0))

    async def commit(self):
        self.commits += 1


def test_a_batch_deletes_the_oldest_rows_before_the_cutoff():
    cutoff = NOW - timedelta(days=30)
    statement = retention.expired_rows(AnalyticsAppearance, AnalyticsAppearance.started_at, cutoff, 50)
    query = sql(statement)
    assert query.startswith("DELETE FROM analytics_appearances WHERE analytics_appearances.id IN (SELECT")
    assert "WHERE analytics_appearances.started_at < %(started_at_1)s" in query
    assert "ORDER BY analytics_appearances.id LIMIT %(param_1)s" in query
    values = statement.compile(dialect=postgresql.dialect()).params
    assert values["started_at_1"] == cutoff
    assert values["param_1"] == 50


async def test_appearances_and_journeys_follow_the_event_retention(monkeypatch):
    monkeypatch.setattr(retention, "PURGE_BATCH", 2)
    session = FakeSession([2, 2, 1, 0])
    deleted = await retention.purge_expired_journeys(session, NOW, 30)
    assert deleted == (5, 0)
    tables = [statement.table.name for statement in session.statements]
    assert tables == ["analytics_appearances"] * 3 + ["analytics_journeys"]
    assert session.commits == 4
    cutoff = statement_cutoff(session.statements[-1])
    assert cutoff == NOW - timedelta(days=30)


async def test_counts_keep_their_own_retention():
    session = FakeSession([3])
    assert await retention.purge_expired_counts(session, NOW, 400) == 3
    (statement,) = session.statements
    assert statement.table.name == AnalyticsCount.__tablename__
    assert "analytics_counts.start <" in sql(statement)
    assert statement_cutoff(statement) == NOW - timedelta(days=400)


def statement_cutoff(statement):
    values = statement.compile(dialect=postgresql.dialect()).params
    return next(value for key, value in values.items() if isinstance(value, datetime))


def test_journeys_are_matched_by_their_start():
    query = sql(retention.expired_rows(AnalyticsJourney, AnalyticsJourney.started_at, NOW))
    assert "analytics_journeys.started_at < %(started_at_1)s" in query
