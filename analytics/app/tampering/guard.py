"""Tamper guard on keyframe thumbnails: covered, blurred, too dark and moved views, adapting to day and night.

The guard samples a view's small grey keyframe band at most once per interval and compares it with what the view
normally shows. It keeps one learned reference per lighting regime, because a camera switching to infrared at dusk
changes brightness, contrast and noise at once while the scene stays where it is. A regime change is known from a
night hint when the caller has one, such as the chroma of a colour thumbnail, which is zero under infrared, or is
inferred from a sudden brightness step that keeps the picture structured. Every regime change starts a short grace
during which no condition can start.

- covered: the picture turns flat, its contrast far below what the view shows at that brightness. On a view with
  little structure, such as a blank wall, a large brightness change must come with it.
- dark: the picture is too dark to see anything, below an absolute floor and a share of the darkest regime, while
  it still has the contrast a dark scene keeps.
- blurred: the picture still lines up with the reference brightness pattern, but its gradients lost their energy
  and no longer line up, which a change of brightness or gain does not cause.
- moved: the gradient structure no longer lines up with the reference. It is not measured on moving lenses or on
  views whose structure is too weak or too unstable to compare, such as a blank wall with sensor noise. A moving
  lens whose structure stops lining up has turned, by a person or by the camera's own tracking, so its reference
  starts again from the new picture instead of calling the new place blurred.

A condition must hold for several samples before it starts and stop for a few before it ends. The reference stops
learning while a condition holds, and a moved condition that lasts long enough becomes the new reference, so a
deliberate re-aim ends it by itself.
"""

from __future__ import annotations

from dataclasses import dataclass, field

import numpy as np

from app.tamper import correlation, gradients

CONDITIONS = ("covered", "blurred", "dark", "moved")

BRIGHTNESS_OFFSET = 10.0
CHROMA_CENTRE = 128.0


@dataclass(frozen=True)
class GuardSettings:
    """Thresholds of the tamper guard; brightness values are on the 0 to 255 grey scale of the thumbnail.

    The view's raw configuration may override any of them under the key tamper_settings.

    Attributes:
        interval: Seconds between two samples; keyframes in between are ignored.
        hold: Samples a condition must hold before it starts.
        hold_moved: Samples a moved condition must hold before it starts.
        clear: Samples a condition must be absent before it ends.
        warmup: Samples a regime needs before its relative checks run.
        grace: Samples after a regime change during which no condition starts.
        accept_moved: Samples after which a lasting moved condition becomes the new reference.
        learning_rate: Weight of a new sample in a warm regime's reference.
        flat_std: Contrast below which a picture is flat whatever the view normally shows.
        cover_ratio: Share of the contrast the view shows at the same brightness below which the picture is flat.
        cover_change: Brightness change a flat picture must also show on a view with little structure.
        dark_floor: Brightness below which a picture is always too dark.
        dark_mean: Brightness ceiling of the relative darkness check.
        dark_ratio: Share of the darkest regime's brightness below which a picture is too dark.
        blur_scene: Share of the view's normal gradient correlation below which a picture that still shows the same
            place is blurred.
        blur_energy: Share of the reference mean gradient below which a picture that still shows the same place is
            blurred.
        same_place: Brightness pattern correlation with the reference at which a picture still shows the same place.
        move_correlation: Gradient correlation with the reference below which the scene changed.
        move_relative: Share of the view's normal correlation below which the scene changed, for noisy views.
        recognise: Gradient correlation at which a picture is taken as showing a known regime's scene.
        texture_edges: Mean gradient below which a view has too little structure for blur and move checks.
        min_stability: Normal correlation below which a view's structure is too unstable for blur and move checks.
        switch_step: Brightness step between two samples that may mean a regime change.
        switch_ratio: Brightness ratio between two samples that may mean a regime change, and the ratio within which
            a known regime's brightness must lie to be taken for it.
    """

    interval: float = 5.0
    hold: int = 3
    hold_moved: int = 6
    clear: int = 2
    warmup: int = 4
    grace: int = 3
    accept_moved: int = 60
    learning_rate: float = 0.05

    flat_std: float = 4.0
    cover_ratio: float = 0.3
    cover_change: float = 25.0

    dark_floor: float = 15.0
    dark_mean: float = 40.0
    dark_ratio: float = 0.3

    blur_scene: float = 0.6
    blur_energy: float = 0.85
    same_place: float = 0.7
    move_correlation: float = 0.4
    move_relative: float = 0.55
    recognise: float = 0.5

    texture_edges: float = 4.5
    min_stability: float = 0.5

    switch_step: float = 20.0
    switch_ratio: float = 1.35

    @classmethod
    def from_dict(cls, data: dict | None) -> GuardSettings:
        """Build the settings from a view's tamper_settings mapping, keeping defaults for missing keys.

        Args:
            data: Setting names to numbers, or None.

        Returns:
            The settings.
        """
        defaults = cls()
        known = {
            name: type(getattr(defaults, name))(value)
            for name, value in (data or {}).items()
            if name in cls.__dataclass_fields__
        }
        return cls(**known)


def night_from_chroma(u: np.ndarray, v: np.ndarray, limit: float = 3.0) -> bool:
    """Tell from the chroma planes of a thumbnail whether the camera is in infrared night mode.

    Infrared pictures carry no colour, so both chroma planes sit at their neutral value.

    Args:
        u: The U plane.
        v: The V plane.
        limit: Largest mean distance from neutral that still counts as no colour.

    Returns:
        True when the picture has no colour.
    """
    spread = float(np.abs(u.astype(np.float32) - CHROMA_CENTRE).mean())
    spread += float(np.abs(v.astype(np.float32) - CHROMA_CENTRE).mean())
    return spread / 2 < limit


def brightness_ratio(first: float, second: float) -> float:
    """Return how many times brighter the brighter of two brightness levels is.

    Args:
        first: One brightness.
        second: The other.

    Returns:
        A ratio of at least 1, with a small offset so near-black levels do not explode it.
    """
    low, high = sorted((first, second))
    return (high + BRIGHTNESS_OFFSET) / (low + BRIGHTNESS_OFFSET)


@dataclass(frozen=True)
class Sample:
    """Measurements of one keyframe band.

    Attributes:
        image: The band.
        mean: Mean brightness.
        std: Contrast as the standard deviation of brightness.
        edges: Gradient magnitude map.
        energy: Mean gradient magnitude.
    """

    image: np.ndarray
    mean: float
    std: float
    edges: np.ndarray
    energy: float

    @classmethod
    def measure(cls, image: np.ndarray) -> Sample:
        """Measure a grey band.

        Args:
            image: The band as float32.

        Returns:
            The measurements.
        """
        edges = gradients(image)
        return cls(image, float(image.mean()), float(image.std()), edges, float(edges.mean()))


@dataclass(eq=False)
class Regime:
    """What a view normally shows under one lighting, such as day or infrared night.

    Attributes:
        night: True for infrared night, False for day, None when no hint said which.
        image: Learned brightness pattern.
        edges: Learned gradient map.
        mean: Learned brightness.
        std: Learned contrast.
        energy: Learned mean gradient.
        stability: Normal correlation of a sample with the learned map, None until measured.
        samples: Samples learned.
    """

    night: bool | None
    image: np.ndarray
    edges: np.ndarray
    mean: float
    std: float
    energy: float
    stability: float | None = None
    samples: int = 1

    @classmethod
    def start(cls, sample: Sample, night: bool | None) -> Regime:
        """Start a regime from its first sample.

        Args:
            sample: The first sample.
            night: Night hint, or None.

        Returns:
            The regime.
        """
        return cls(night, sample.image.copy(), sample.edges.copy(), sample.mean, sample.std, sample.energy)

    def warm(self, settings: GuardSettings) -> bool:
        """Tell whether the regime learned enough samples for its relative checks.

        Args:
            settings: Guard settings.

        Returns:
            True once warm.
        """
        return self.samples >= settings.warmup

    def textured(self, settings: GuardSettings) -> bool:
        """Tell whether the view's structure is strong and stable enough for the blur and move checks.

        Args:
            settings: Guard settings.

        Returns:
            True when both checks can be trusted.
        """
        stable = self.stability is not None and self.stability >= settings.min_stability
        return stable and self.energy >= settings.texture_edges

    def expected_std(self, mean: float) -> float:
        """Return the contrast the view normally shows at a brightness.

        Args:
            mean: Brightness of the sample.

        Returns:
            The learned contrast scaled down by the brightness ratio for darker samples, never above the learned
            contrast.
        """
        return self.std * min(1.0, (mean + BRIGHTNESS_OFFSET) / (self.mean + BRIGHTNESS_OFFSET))

    def learn(self, sample: Sample, scene: float, settings: GuardSettings) -> None:
        """Fold a normal sample into the regime.

        Args:
            sample: The sample.
            scene: Its correlation with the learned map before this update.
            settings: Guard settings.
        """
        rate = 1.0 / (self.samples + 1) if not self.warm(settings) else settings.learning_rate
        self.image = (1 - rate) * self.image + rate * sample.image
        self.edges = (1 - rate) * self.edges + rate * sample.edges
        self.mean = (1 - rate) * self.mean + rate * sample.mean
        self.std = (1 - rate) * self.std + rate * sample.std
        self.energy = (1 - rate) * self.energy + rate * sample.energy
        if self.stability is None:
            self.stability = scene
        else:
            self.stability = (1 - rate) * self.stability + rate * scene
        self.samples += 1


@dataclass(eq=False)
class TamperGuard:
    """Tamper state of one view.

    Attributes:
        settings: Thresholds.
        moving: True for a moving lens, whose scene changes on purpose, so moved is never reported.
        regimes: Learned regimes, at most two.
        current: The regime the latest sample belongs to.
        grace: Samples left in the grace after a regime change.
        last_at: Time of the latest sample.
        previous_mean: Brightness of the previous sample.
        streaks: Consecutive samples each condition held.
        clears: Consecutive samples each active condition was absent.
        active: Conditions currently reported.
        last: Measurements of the latest sample for the status endpoint.
    """

    settings: GuardSettings = field(default_factory=GuardSettings)
    moving: bool = False
    regimes: list[Regime] = field(default_factory=list)
    current: Regime | None = None
    grace: int = 0
    last_at: float | None = None
    previous_mean: float | None = None
    streaks: dict[str, int] = field(default_factory=lambda: {name: 0 for name in CONDITIONS})
    clears: dict[str, int] = field(default_factory=lambda: {name: 0 for name in CONDITIONS})
    active: set[str] = field(default_factory=set)
    last: dict = field(default_factory=dict)

    def update(self, image: np.ndarray, at: float, night: bool | None = None) -> tuple[set[str], set[str]]:
        """Fold one keyframe band in, at most once per interval.

        Args:
            image: Grey band of the view as float32.
            at: Time of the keyframe.
            night: True under infrared, False by day, None when the caller cannot tell.

        Returns:
            Conditions that started and conditions that ended with this sample.
        """
        settings = self.settings
        if self.last_at is not None and at - self.last_at < settings.interval:
            return set(), set()
        self.last_at = at
        sample = Sample.measure(image)
        if self.current is None:
            self.current = Regime.start(sample, night)
            self.regimes = [self.current]
            self.previous_mean = sample.mean
            self.record(sample, 1.0)
            return set(), set()
        switched = self.switch(sample, night)
        regime = self.current
        scene = correlation(sample.edges, regime.edges)
        if switched or self.grace > 0:
            if not switched:
                self.grace -= 1
            conditions = dict.fromkeys(CONDITIONS, False)
        else:
            conditions = self.evaluate(sample, regime, scene)
        turned = (
            self.moving
            and not (conditions["covered"] or conditions["dark"])
            and regime.warm(settings)
            and scene < settings.move_correlation
        )
        if turned:
            conditions["blurred"] = False
        started, ended = self.advance(conditions)
        if turned:
            self.current = Regime.start(sample, regime.night)
            self.regimes = [self.current]
            self.streaks = dict.fromkeys(CONDITIONS, 0)
            for name in ("blurred", "moved"):
                if name in self.active:
                    self.active.discard(name)
                    ended.add(name)
        elif self.streaks["moved"] >= settings.accept_moved:
            self.current = Regime.start(sample, regime.night)
            self.regimes = [self.current]
            self.streaks = dict.fromkeys(CONDITIONS, 0)
            if "moved" in self.active:
                self.active.discard("moved")
                ended.add("moved")
        elif not any(conditions.values()) and not self.flat(sample, regime) and sample.mean >= self.dark_limit():
            regime.learn(sample, scene, settings)
        self.previous_mean = sample.mean
        self.record(sample, scene)
        return started, ended

    def advance(self, conditions: dict[str, bool]) -> tuple[set[str], set[str]]:
        """Update the streaks and decide which conditions start and end.

        During a grace every condition is passed as absent, so nothing starts and active conditions clear.

        Args:
            conditions: Whether each condition holds in this sample.

        Returns:
            Conditions that started and conditions that ended.
        """
        started, ended = set(), set()
        for name in CONDITIONS:
            if conditions[name]:
                self.streaks[name] += 1
                self.clears[name] = 0
                hold = self.settings.hold_moved if name == "moved" else self.settings.hold
                if self.streaks[name] >= hold and name not in self.active:
                    self.active.add(name)
                    started.add(name)
                continue
            self.streaks[name] = 0
            if name in self.active:
                self.clears[name] += 1
                if self.clears[name] >= self.settings.clear:
                    self.active.discard(name)
                    self.clears[name] = 0
                    ended.add(name)
        return started, ended

    def switch(self, sample: Sample, night: bool | None) -> bool:
        """Detect a change of lighting regime and select or start the matching regime.

        Args:
            sample: The new sample.
            night: Night hint, or None.

        Returns:
            True when the regime changed, which starts a grace.
        """
        settings = self.settings
        current = self.current
        if night is not None:
            if current.night is None:
                current.night = night
                return False
            if night == current.night:
                return False
            target = next((regime for regime in self.regimes if regime.night == night), None)
            if target is None:
                target = Regime.start(sample, night)
                self.add(target)
            self.current = target
            self.grace = settings.grace
            return True
        previous = self.previous_mean if self.previous_mean is not None else sample.mean
        if abs(sample.mean - previous) < settings.switch_step:
            return False
        if brightness_ratio(previous, sample.mean) < settings.switch_ratio:
            return False
        if self.flat(sample, current) or sample.mean < self.dark_limit():
            return False
        known = [regime for regime in self.regimes if correlation(sample.edges, regime.edges) >= settings.recognise]
        close = [regime for regime in known if brightness_ratio(regime.mean, sample.mean) < settings.switch_ratio]
        if close:
            self.current = min(close, key=lambda regime: brightness_ratio(regime.mean, sample.mean))
        elif len(self.regimes) < 2 or not known:
            self.current = Regime.start(sample, None)
            self.add(self.current)
        else:
            self.current = min(known, key=lambda regime: brightness_ratio(regime.mean, sample.mean))
        self.grace = settings.grace
        return True

    def add(self, regime: Regime) -> None:
        """Keep a new regime, replacing the one not in use when two exist.

        Args:
            regime: The new regime.
        """
        if len(self.regimes) >= 2:
            self.regimes = [item for item in self.regimes if item is self.current][:1]
        self.regimes.append(regime)

    def dark_limit(self) -> float:
        """Return the brightness below which a picture is too dark.

        Returns:
            The absolute floor, raised to a share of the darkest warm regime up to the relative ceiling.
        """
        settings = self.settings
        warm = [regime.mean for regime in self.regimes if regime.warm(settings)]
        if not warm:
            return settings.dark_floor
        return max(settings.dark_floor, min(settings.dark_mean, settings.dark_ratio * min(warm)))

    def flat(self, sample: Sample, regime: Regime) -> bool:
        """Tell whether a sample is flat compared with what the view shows at its brightness.

        Args:
            sample: The sample.
            regime: The regime to compare with.

        Returns:
            True for a covered lens.
        """
        settings = self.settings
        if not regime.warm(settings):
            return sample.std < settings.flat_std and sample.mean < settings.dark_floor
        limit = max(settings.flat_std, settings.cover_ratio * regime.expected_std(sample.mean))
        if sample.std >= limit:
            return False
        if regime.textured(settings):
            return True
        change = abs(sample.mean - regime.mean)
        return change >= max(settings.cover_change, 0.3 * regime.mean) or sample.std < settings.flat_std

    def evaluate(self, sample: Sample, regime: Regime, scene: float) -> dict[str, bool]:
        """Decide which conditions hold for a sample.

        Args:
            sample: The sample.
            regime: The current regime.
            scene: Correlation of the sample's gradients with the regime's map.

        Returns:
            Whether each condition holds.
        """
        settings = self.settings
        covered = self.flat(sample, regime)
        dark = not covered and sample.mean < self.dark_limit()
        result = {"covered": covered, "dark": dark, "blurred": False, "moved": False}
        if covered or dark or not regime.warm(settings) or not regime.textured(settings):
            return result
        stability = regime.stability or 1.0
        place = correlation(sample.image, regime.image)
        weaker = sample.energy < settings.blur_energy * regime.energy
        result["blurred"] = place >= settings.same_place and weaker and scene < settings.blur_scene * stability
        if not self.moving and not result["blurred"]:
            result["moved"] = scene < min(settings.move_correlation, settings.move_relative * stability)
        return result

    def record(self, sample: Sample, scene: float) -> None:
        """Keep the latest measurements for the status endpoint.

        Args:
            sample: The latest sample.
            scene: Its correlation with the current regime.
        """
        regime = self.current
        mode = "unknown" if regime.night is None else ("night" if regime.night else "day")
        self.last = {
            "mean": round(sample.mean, 1),
            "std": round(sample.std, 1),
            "edges": round(sample.energy, 2),
            "scene": round(scene, 3),
            "stability": round(regime.stability, 3) if regime.stability is not None else None,
            "textured": regime.textured(self.settings),
            "regime": next(index for index, item in enumerate(self.regimes) if item is regime),
            "regimes": len(self.regimes),
            "mode": mode,
            "grace": self.grace,
        }

    def rebase(self) -> None:
        """Forget everything learned, for instance after the owner moved a camera on purpose."""
        self.regimes = []
        self.current = None
        self.grace = 0
        self.previous_mean = None
        self.active.clear()
        self.streaks = dict.fromkeys(CONDITIONS, 0)
        self.clears = dict.fromkeys(CONDITIONS, 0)
