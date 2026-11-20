"""Invitation endpoints."""

from uuid import UUID

from fastapi import APIRouter, Depends, Response, status

from app.modules.organisations.deps import (
    get_invitation_service,
    get_organisation_service,
    get_public_invitation_service,
)
from app.modules.organisations.schemas import (
    InvitationCreate,
    InvitationList,
    InvitationPreview,
    InvitationRead,
    OrganisationRead,
)
from app.modules.organisations.services import InvitationService, OrganisationService

router = APIRouter()


@router.get("/organisations/{organisation}/invitations", response_model=InvitationList)
async def list_invitations(
    organisation: UUID, service: InvitationService = Depends(get_invitation_service)
) -> InvitationList:
    """List the invitations of an organisation; admins and owners only.

    Args:
        organisation: Public id of the organisation.
        service: Invitation service.

    Returns:
        The invitations.
    """
    return await service.list(organisation)


@router.post(
    "/organisations/{organisation}/invitations", response_model=InvitationRead, status_code=status.HTTP_201_CREATED
)
async def create_invitation(
    organisation: UUID, payload: InvitationCreate, service: InvitationService = Depends(get_invitation_service)
) -> InvitationRead:
    """Invite an email address with a role and a site scope and mail it the link; admins and owners only.

    Args:
        organisation: Public id of the organisation.
        payload: The invitation.
        service: Invitation service.

    Returns:
        The invitation.
    """
    return await service.create(organisation, payload)


@router.delete(
    "/organisations/{organisation}/invitations/{invitation}",
    status_code=status.HTTP_204_NO_CONTENT,
    response_class=Response,
)
async def revoke_invitation(
    organisation: UUID, invitation: UUID, service: InvitationService = Depends(get_invitation_service)
) -> Response:
    """Withdraw a pending invitation; admins and owners only.

    Args:
        organisation: Public id of the organisation.
        invitation: Public id of the invitation.
        service: Invitation service.

    Returns:
        Empty response.
    """
    await service.revoke(organisation, invitation)
    return Response(status_code=status.HTTP_204_NO_CONTENT)


@router.get("/invitations/{token}", response_model=InvitationPreview)
async def preview_invitation(
    token: str, service: InvitationService = Depends(get_public_invitation_service)
) -> InvitationPreview:
    """Describe what an invitation link offers, without signing in.

    Args:
        token: Token from the invitation link.
        service: Invitation service.

    Returns:
        The organisation, role, inviter and state of the invitation.
    """
    return await service.preview(token)


@router.post("/invitations/{token}/accept", response_model=OrganisationRead)
async def accept_invitation(
    token: str,
    service: InvitationService = Depends(get_invitation_service),
    organisations: OrganisationService = Depends(get_organisation_service),
) -> OrganisationRead:
    """Accept an invitation as the signed-in user, who must own the confirmed invited address.

    Args:
        token: Token from the invitation link.
        service: Invitation service.
        organisations: Organisation service.

    Returns:
        The organisation joined.
    """
    return await organisations.read(await service.accept(token))
