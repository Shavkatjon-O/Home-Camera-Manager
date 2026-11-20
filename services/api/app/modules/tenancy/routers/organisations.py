"""Organisation endpoints."""

from uuid import UUID

from fastapi import APIRouter, Depends, Response, status

from app.modules.organisations.deps import get_organisation_service
from app.modules.organisations.schemas import (
    FacesConsent,
    OrganisationCreate,
    OrganisationList,
    OrganisationRead,
    OrganisationUpdate,
    OwnershipTransfer,
)
from app.modules.organisations.services import FACES_CONSENT, OrganisationService

router = APIRouter()


@router.get("", response_model=OrganisationList)
async def list_organisations(service: OrganisationService = Depends(get_organisation_service)) -> OrganisationList:
    """List the organisations the signed-in user belongs to.

    Args:
        service: Organisation service.

    Returns:
        The organisations with the sites the user may reach.
    """
    return await service.list()


@router.post("", response_model=OrganisationRead, status_code=status.HTTP_201_CREATED)
async def create_organisation(
    payload: OrganisationCreate, service: OrganisationService = Depends(get_organisation_service)
) -> OrganisationRead:
    """Create an organisation, of which the signed-in user becomes the owner, with an optional first site.

    Args:
        payload: The organisation.
        service: Organisation service.

    Returns:
        The new organisation.
    """
    return await service.create(payload)


@router.get("/faces-consent", response_model=FacesConsent)
async def get_faces_consent() -> FacesConsent:
    """Return the consent text shown before face recognition is turned on.

    Returns:
        The text and its version.
    """
    return FACES_CONSENT


@router.get("/{organisation}", response_model=OrganisationRead)
async def get_organisation(
    organisation: UUID, service: OrganisationService = Depends(get_organisation_service)
) -> OrganisationRead:
    """Return one organisation of the signed-in user.

    Args:
        organisation: Public id of the organisation.
        service: Organisation service.

    Returns:
        The organisation.
    """
    return await service.read(organisation)


@router.patch("/{organisation}", response_model=OrganisationRead)
async def update_organisation(
    organisation: UUID, payload: OrganisationUpdate, service: OrganisationService = Depends(get_organisation_service)
) -> OrganisationRead:
    """Rename an organisation or turn face recognition on or off; admins and owners only.

    Args:
        organisation: Public id of the organisation.
        payload: Fields to change.
        service: Organisation service.

    Returns:
        The organisation.
    """
    return await service.update(organisation, payload)


@router.delete("/{organisation}", status_code=status.HTTP_204_NO_CONTENT, response_class=Response)
async def delete_organisation(
    organisation: UUID, service: OrganisationService = Depends(get_organisation_service)
) -> Response:
    """Delete an organisation with its sites, cameras and connectors; the owner only.

    Args:
        organisation: Public id of the organisation.
        service: Organisation service.

    Returns:
        Empty response.
    """
    await service.delete(organisation)
    return Response(status_code=status.HTTP_204_NO_CONTENT)


@router.post("/{organisation}/transfer", response_model=OrganisationRead)
async def transfer_ownership(
    organisation: UUID, payload: OwnershipTransfer, service: OrganisationService = Depends(get_organisation_service)
) -> OrganisationRead:
    """Make another member the owner; the owner only.

    Args:
        organisation: Public id of the organisation.
        payload: The member who becomes the owner.
        service: Organisation service.

    Returns:
        The organisation.
    """
    return await service.transfer(organisation, payload.member)
