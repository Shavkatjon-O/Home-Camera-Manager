"""Site endpoints."""

from uuid import UUID

from fastapi import APIRouter, Depends, Response, status

from app.modules.organisations.deps import get_site_service
from app.modules.organisations.schemas import SiteCreate, SiteList, SiteRead, SiteUpdate
from app.modules.organisations.services import SiteService

router = APIRouter()


@router.get("/sites", response_model=SiteList)
async def list_sites(service: SiteService = Depends(get_site_service)) -> SiteList:
    """List every site the signed-in user may reach, for the site switcher.

    Args:
        service: Site service.

    Returns:
        The sites by organisation and position.
    """
    return await service.list_all()


@router.get("/organisations/{organisation}/sites", response_model=SiteList)
async def list_organisation_sites(organisation: UUID, service: SiteService = Depends(get_site_service)) -> SiteList:
    """List the sites of one organisation that the signed-in user may reach.

    Args:
        organisation: Public id of the organisation.
        service: Site service.

    Returns:
        The sites.
    """
    return await service.list(organisation)


@router.post("/organisations/{organisation}/sites", response_model=SiteRead, status_code=status.HTTP_201_CREATED)
async def create_site(
    organisation: UUID, payload: SiteCreate, service: SiteService = Depends(get_site_service)
) -> SiteRead:
    """Add a site to an organisation; admins of every site and owners only.

    Args:
        organisation: Public id of the organisation.
        payload: The site.
        service: Site service.

    Returns:
        The new site.
    """
    return await service.create(organisation, payload)


@router.get("/sites/{site}", response_model=SiteRead)
async def get_site(site: UUID, service: SiteService = Depends(get_site_service)) -> SiteRead:
    """Return one site.

    Args:
        site: Public id of the site.
        service: Site service.

    Returns:
        The site.
    """
    return await service.read(site)


@router.patch("/sites/{site}", response_model=SiteRead)
async def update_site(site: UUID, payload: SiteUpdate, service: SiteService = Depends(get_site_service)) -> SiteRead:
    """Rename a site or change its kind, time zone or position; admins and owners only.

    Args:
        site: Public id of the site.
        payload: Fields to change.
        service: Site service.

    Returns:
        The site.
    """
    return await service.update(site, payload)


@router.delete("/sites/{site}", status_code=status.HTTP_204_NO_CONTENT, response_class=Response)
async def delete_site(site: UUID, service: SiteService = Depends(get_site_service)) -> Response:
    """Remove a site with its cameras and connectors; admins of every site and owners only.

    Args:
        site: Public id of the site.
        service: Site service.

    Returns:
        Empty response.
    """
    await service.delete(site)
    return Response(status_code=status.HTTP_204_NO_CONTENT)
