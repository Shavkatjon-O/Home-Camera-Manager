"""The analytics service status as members of a site see it."""

from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.analytics.observations import Observations, observations
from app.models import AnalyticsView
from app.modules.analytics.schemas import AnalyticsStatus

__all__ = ["AnalyticsStatusService"]


class AnalyticsStatusService:
    """Reads the latest status the analytics service reported, limited to the site's views.

    Attributes:
        session: Database session limited to the request's site.
        reported: Store of what the analytics service last reported.
    """

    def __init__(self, session: AsyncSession, reported: Observations = observations):
        """Bind the service to a scoped session.

        Args:
            session: Database session limited to the request's site.
            reported: Store of the analytics service's reports.
        """
        self.session = session
        self.reported = reported

    async def read(self) -> AnalyticsStatus:
        """Return the status with the views of the session's site only.

        Returns:
            The status.
        """
        site_views = {str(uuid) for uuid in await self.session.scalars(select(AnalyticsView.uuid))}
        return AnalyticsStatus(
            pipeline=self.reported.pipeline,
            gpu=self.reported.gpu,
            updated_at=self.reported.updated_at,
            views={key: value for key, value in self.reported.views.items() if key in site_views},
        )
