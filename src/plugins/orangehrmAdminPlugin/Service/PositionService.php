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

namespace OrangeHRM\Admin\Service;

use OrangeHRM\Admin\Dao\PositionDao;
use OrangeHRM\Admin\Service\Model\PositionModel;
use OrangeHRM\Core\Traits\Service\NormalizerServiceTrait;
use OrangeHRM\Entity\Position;

class PositionService
{
    use NormalizerServiceTrait;

    /**
     * @var PositionDao|null
     */
    private ?PositionDao $positionDao = null;

    /**
     * @return PositionDao
     */
    public function getPositionDao(): PositionDao
    {
        if (!($this->positionDao instanceof PositionDao)) {
            $this->positionDao = new PositionDao();
        }
        return $this->positionDao;
    }

    /**
     * @param PositionDao $positionDao
     */
    public function setPositionDao(PositionDao $positionDao): void
    {
        $this->positionDao = $positionDao;
    }

    /**
     * Returns Position list - By default this will returns the active position list
     * To get all the positions (with deleted) should pass the $activeOnly as false
     *
     * @param bool $activeOnly
     * @return Position[]
     */
    public function getPositionList(bool $activeOnly = true): array
    {
        return $this->getPositionDao()->getPositionList($activeOnly);
    }

    /**
     * This will flag the positions as deleted
     *
     * @param array $toBeDeletedPositionIds
     * @return int number of affected rows
     */
    public function deletePosition(array $toBeDeletedPositionIds): int
    {
        return $this->getPositionDao()->deletePosition($toBeDeletedPositionIds);
    }

    /**
     * Will return the Position doctrine object for a particular id
     *
     * @param int $positionId
     * @return Position|null
     */
    public function getPositionById(int $positionId): ?Position
    {
        return $this->getPositionDao()->getPositionById($positionId);
    }

    /**
     * @param Position $position
     * @return Position
     */
    public function savePosition(Position $position): Position
    {
        return $this->getPositionDao()->savePosition($position);
    }

    /**
     * @return array
     */
    public function getPositionArray(): array
    {
        $positions = $this->getPositionList();
        return $this->getNormalizerService()->normalizeArray(PositionModel::class, $positions);
    }

    /**
     * @param int $empNumber
     * @return array
     */
    public function getPositionArrayForEmployee(int $empNumber): array
    {
        $positions = $this->getPositionDao()->getPositionsForEmployee($empNumber);
        return $this->getNormalizerService()->normalizeArray(PositionModel::class, $positions);
    }
}

