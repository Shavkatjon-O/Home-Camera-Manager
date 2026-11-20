"""Routes for unknown face clusters."""

from uuid import UUID

from fastapi import APIRouter, Depends, Query, Response, status

from app.modules.investigation.deps import get_cluster_service
from app.modules.investigation.schemas import ClusterList, ClusterMerge, ClusterName, ClusterRead, PersonRead
from app.modules.investigation.services import ClusterService
from app.modules.tenancy.deps import require_admin

router = APIRouter()

PAGE_SIZE_DEFAULT = 50
PAGE_SIZE_MAX = 200


@router.get("", dependencies=[Depends(require_admin)], response_model=ClusterList)
async def list_clusters(
    page: int = Query(1, ge=1),
    page_size: int = Query(PAGE_SIZE_DEFAULT, ge=1, le=PAGE_SIZE_MAX),
    service: ClusterService = Depends(get_cluster_service),
) -> ClusterList:
    """List unknown clusters, the most recently seen first.

    Args:
        page: One-based page number.
        page_size: Number of clusters per page.
        service: Cluster service for the signed-in user.

    Returns:
        One page of clusters with the total count.
    """
    return await service.list_page(page, page_size)


@router.post("/{uuid}/name", dependencies=[Depends(require_admin)], response_model=PersonRead)
async def name_cluster(
    uuid: UUID,
    payload: ClusterName,
    service: ClusterService = Depends(get_cluster_service),
) -> PersonRead:
    """Name an unknown cluster after an existing or a new person.

    Args:
        uuid: Public id of the cluster.
        payload: The person to join or the name of a new one.
        service: Cluster service for the signed-in user.

    Returns:
        The person the cluster became.
    """
    return await service.name(uuid, payload)


@router.post("/{uuid}/merge", dependencies=[Depends(require_admin)], response_model=ClusterRead)
async def merge_cluster(
    uuid: UUID,
    payload: ClusterMerge,
    service: ClusterService = Depends(get_cluster_service),
) -> ClusterRead:
    """Merge an unknown cluster into another.

    Args:
        uuid: Public id of the cluster that goes away.
        payload: The cluster that remains.
        service: Cluster service for the signed-in user.

    Returns:
        The remaining cluster.
    """
    return await service.merge(uuid, payload.into)


@router.delete("/{uuid}", dependencies=[Depends(require_admin)], status_code=status.HTTP_204_NO_CONTENT)
async def delete_cluster(uuid: UUID, service: ClusterService = Depends(get_cluster_service)) -> Response:
    """Delete an unknown cluster with its samples and crops.

    Args:
        uuid: Public id of the cluster.
        service: Cluster service for the signed-in user.

    Returns:
        Empty response.
    """
    await service.delete(uuid)
    return Response(status_code=status.HTTP_204_NO_CONTENT)
