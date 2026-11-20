"""Member endpoints."""

from uuid import UUID

from fastapi import APIRouter, Depends, Response, status

from app.modules.organisations.deps import get_member_service
from app.modules.organisations.schemas import MemberList, MemberRead, MemberUpdate
from app.modules.organisations.services import MemberService

router = APIRouter()


@router.get("/{organisation}/members", response_model=MemberList)
async def list_members(organisation: UUID, service: MemberService = Depends(get_member_service)) -> MemberList:
    """List the members of an organisation; admins and owners only.

    Args:
        organisation: Public id of the organisation.
        service: Member service.

    Returns:
        The members.
    """
    return await service.list(organisation)


@router.patch("/{organisation}/members/{member}", response_model=MemberRead)
async def update_member(
    organisation: UUID, member: UUID, payload: MemberUpdate, service: MemberService = Depends(get_member_service)
) -> MemberRead:
    """Change a member's role or sites; admins and owners only, never the owner's own membership.

    Args:
        organisation: Public id of the organisation.
        member: Public id of the membership.
        payload: Fields to change.
        service: Member service.

    Returns:
        The member.
    """
    return await service.update(organisation, member, payload)


@router.delete("/{organisation}/members/{member}", status_code=status.HTTP_204_NO_CONTENT, response_class=Response)
async def remove_member(
    organisation: UUID, member: UUID, service: MemberService = Depends(get_member_service)
) -> Response:
    """Remove a member, or leave the organisation when the membership is the caller's own.

    Args:
        organisation: Public id of the organisation.
        member: Public id of the membership.
        service: Member service.

    Returns:
        Empty response.
    """
    await service.remove(organisation, member)
    return Response(status_code=status.HTTP_204_NO_CONTENT)
