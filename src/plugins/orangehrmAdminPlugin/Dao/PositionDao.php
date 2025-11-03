<?php
/**
 * OrangeHRM is a comprehensive Human Resource Management (HRM) System that captures
 * all the essential functionalities required for any enterprise.
 * Copyright (C) 2006 OrangeHRM Inc., http://www.orangehrm.com
 *
 * OrangeHRM is free software: you can redistribute it and/or modify it under the terms of
 * the GNU General Public License as published by the Free Software Foundation, either
 * version 3 of the License, or (at your option) any later version.
 *
 * OrangeHRM is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
 * without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 * See the GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along with OrangeHRM.
 * If not, see <https://www.gnu.org/licenses/>.
 */

namespace OrangeHRM\Admin\Dao;

use OrangeHRM\Admin\Dto\PositionSearchFilterParams;
use OrangeHRM\Core\Dao\BaseDao;
use OrangeHRM\Entity\Position;
use OrangeHRM\ORM\ListSorter;
use OrangeHRM\ORM\Paginator;

class PositionDao extends BaseDao
{
    /**
     * @param bool $activeOnly
     * @return Position[]
     */
    public function getPositionList(bool $activeOnly = true): array
    {
        $q = $this->createQueryBuilder(Position::class, 'p');
        if ($activeOnly == true) {
            $q->andWhere('p.isDeleted = :isDeleted');
            $q->setParameter('isDeleted', Position::ACTIVE);
        }
        $q->addOrderBy('p.name', ListSorter::ASCENDING);

        return $q->getQuery()->execute();
    }

    /**
     * @param int $empNumber
     * @return Position[]
     */
    public function getPositionsForEmployee(int $empNumber): array
    {
        $q = $this->createQueryBuilder(Position::class, 'p');
        $q->leftJoin('p.employees', 'e');
        $q->andWhere('p.isDeleted = :isDeleted')
            ->setParameter('isDeleted', Position::ACTIVE);
        $q->orWhere('e.empNumber = :empNumber')
            ->setParameter('empNumber', $empNumber);

        $q->addOrderBy('p.name', ListSorter::ASCENDING);

        return $q->getQuery()->execute();
    }

    /**
     * @param PositionSearchFilterParams $positionSearchFilterParams
     * @return Position[]
     */
    public function getPositions(PositionSearchFilterParams $positionSearchFilterParams): array
    {
        return $this->getPositionsPaginator($positionSearchFilterParams)->getQuery()->execute();
    }

    /**
     * @param PositionSearchFilterParams $positionSearchFilterParams
     * @return Paginator
     */
    private function getPositionsPaginator(
        PositionSearchFilterParams $positionSearchFilterParams
    ): Paginator {
        $q = $this->createQueryBuilder(Position::class, 'p');
        $this->setSortingAndPaginationParams($q, $positionSearchFilterParams);
        if ($positionSearchFilterParams->getActiveOnly() == true) {
            $q->andWhere('p.isDeleted = :isDeleted');
            $q->setParameter('isDeleted', Position::ACTIVE);
        }
        return $this->getPaginator($q);
    }

    /**
     * @param PositionSearchFilterParams $positionSearchFilterParams
     * @return int
     */
    public function getPositionsCount(PositionSearchFilterParams $positionSearchFilterParams): int
    {
        return $this->getPositionsPaginator($positionSearchFilterParams)->count();
    }

    /**
     * @param array $toBeDeletedPositionIds
     * @return int
     */
    public function deletePosition(array $toBeDeletedPositionIds): int
    {
        $q = $this->createQueryBuilder(Position::class, 'p');
        $q->update()
            ->set('p.isDeleted', ':isDeleted')
            ->setParameter('isDeleted', Position::DELETED)
            ->where($q->expr()->in('p.id', ':ids'))
            ->setParameter('ids', $toBeDeletedPositionIds);
        return $q->getQuery()->execute();
    }

    /**
     * @param int $positionId
     * @return Position|null
     */
    public function getPositionById(int $positionId): ?Position
    {
        $position = $this->getRepository(Position::class)->find($positionId);
        if ($position instanceof Position) {
            return $position;
        }
        return null;
    }

    /**
     * @param int[] $ids
     * @return int[]
     */
    public function getExistingPositionIds(array $ids): array
    {
        $qb = $this->createQueryBuilder(Position::class, 'position');
        $qb->select('position.id')
            ->andWhere($qb->expr()->in('position.id', ':ids'))
            ->andWhere($qb->expr()->eq('position.isDeleted', ':deleted'))
            ->setParameter('ids', $ids)
            ->setParameter('deleted', false);

        return $qb->getQuery()->getSingleColumnResult();
    }

    /**
     * @param Position $position
     * @return Position
     */
    public function savePosition(Position $position): Position
    {
        $this->persist($position);
        return $position;
    }
}

