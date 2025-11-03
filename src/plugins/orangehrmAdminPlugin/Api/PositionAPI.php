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

namespace OrangeHRM\Admin\Api;

use OrangeHRM\Admin\Api\Model\PositionModel;
use OrangeHRM\Admin\Dto\PositionSearchFilterParams;
use OrangeHRM\Admin\Service\PositionService;
use OrangeHRM\Core\Api\CommonParams;
use OrangeHRM\Core\Api\V2\CrudEndpoint;
use OrangeHRM\Core\Api\V2\Endpoint;
use OrangeHRM\Core\Api\V2\EndpointCollectionResult;
use OrangeHRM\Core\Api\V2\EndpointResourceResult;
use OrangeHRM\Core\Api\V2\EndpointResult;
use OrangeHRM\Core\Api\V2\Model\ArrayModel;
use OrangeHRM\Core\Api\V2\ParameterBag;
use OrangeHRM\Core\Api\V2\RequestParams;
use OrangeHRM\Core\Api\V2\Validator\ParamRule;
use OrangeHRM\Core\Api\V2\Validator\ParamRuleCollection;
use OrangeHRM\Core\Api\V2\Validator\Rule;
use OrangeHRM\Core\Api\V2\Validator\Rules;
use OrangeHRM\Core\Api\V2\Validator\Rules\EntityUniquePropertyOption;
use OrangeHRM\Entity\Position;

class PositionAPI extends Endpoint implements CrudEndpoint
{
    /**
     * @var null|PositionService
     */
    protected ?PositionService $positionService = null;

    public const PARAMETER_NAME = 'name';
    public const PARAMETER_DESCRIPTION = 'description';
    public const PARAMETER_NOTE = 'note';
    public const PARAMETER_ACTIVE_ONLY = 'activeOnly';

    public const PARAM_RULE_NAME_MAX_LENGTH = 100;
    public const PARAM_RULE_DESCRIPTION_MAX_LENGTH = 400;
    public const PARAM_RULE_NOTE_MAX_LENGTH = 400;

    /**
     * @return PositionService
     */
    public function getPositionService(): PositionService
    {
        if (is_null($this->positionService)) {
            $this->positionService = new PositionService();
        }
        return $this->positionService;
    }

    /**
     * @inheritDoc
     */
    public function getOne(): EndpointResult
    {
        $id = $this->getRequestParams()->getInt(RequestParams::PARAM_TYPE_ATTRIBUTE, CommonParams::PARAMETER_ID);
        $position = $this->getPositionService()->getPositionById($id);
        $this->throwRecordNotFoundExceptionIfNotExist($position, Position::class);

        return new EndpointResourceResult(PositionModel::class, $position);
    }

    /**
     * @inheritDoc
     */
    public function getValidationRuleForGetOne(): ParamRuleCollection
    {
        return new ParamRuleCollection(
            new ParamRule(CommonParams::PARAMETER_ID),
        );
    }

    /**
     * @inheritDoc
     */
    public function getAll(): EndpointResult
    {
        $positionSearchFilterParams = new PositionSearchFilterParams();
        $this->setSortingAndPaginationParams($positionSearchFilterParams);

        $activeOnly = $this->getRequestParams()->getBoolean(
            RequestParams::PARAM_TYPE_QUERY,
            self::PARAMETER_ACTIVE_ONLY,
            true
        );
        $positionSearchFilterParams->setActiveOnly($activeOnly);

        $count = $this->getPositionService()->getPositionDao()->getPositionsCount($positionSearchFilterParams);

        $positions = $this->getPositionService()->getPositionDao()->getPositions($positionSearchFilterParams);
        return new EndpointCollectionResult(
            PositionModel::class,
            $positions,
            new ParameterBag([CommonParams::PARAMETER_TOTAL => $count])
        );
    }

    /**
     * @inheritDoc
     */
    public function getValidationRuleForGetAll(): ParamRuleCollection
    {
        return new ParamRuleCollection(
            new ParamRule(
                self::PARAMETER_ACTIVE_ONLY,
                new Rule(Rules::BOOL_VAL)
            ),
            ...$this->getSortingAndPaginationParamsRules(PositionSearchFilterParams::ALLOWED_SORT_FIELDS)
        );
    }

    /**
     * @inheritDoc
     */
    public function create(): EndpointResult
    {
        $position = new Position();
        $this->setPosition($position);
        $position = $this->getPositionService()->savePosition($position);

        return new EndpointResourceResult(PositionModel::class, $position);
    }

    /**
     * @param Position $position
     */
    private function setPosition(Position $position): void
    {
        $position->setName(
            $this->getRequestParams()->getString(
                RequestParams::PARAM_TYPE_BODY,
                self::PARAMETER_NAME
            )
        );
        $position->setDescription(
            $this->getRequestParams()->getStringOrNull(
                RequestParams::PARAM_TYPE_BODY,
                self::PARAMETER_DESCRIPTION
            )
        );
        $position->setNote(
            $this->getRequestParams()->getStringOrNull(
                RequestParams::PARAM_TYPE_BODY,
                self::PARAMETER_NOTE
            )
        );
    }

    /**
     * @inheritDoc
     */
    public function getValidationRuleForCreate(): ParamRuleCollection
    {
        return new ParamRuleCollection(
            ...$this->getCommonBodyValidationRules($this->getPositionCommonUniqueOption()),
        );
    }

    /**
     * @param EntityUniquePropertyOption|null $uniqueOption
     * @return ParamRule[]
     */
    protected function getCommonBodyValidationRules(?EntityUniquePropertyOption $uniqueOption = null): array
    {
        return [
            $this->getValidationDecorator()->requiredParamRule(
                new ParamRule(
                    self::PARAMETER_NAME,
                    new Rule(Rules::STRING_TYPE),
                    new Rule(Rules::LENGTH, [null, self::PARAM_RULE_NAME_MAX_LENGTH]),
                    new Rule(Rules::ENTITY_UNIQUE_PROPERTY, [Position::class, 'name', $uniqueOption])
                )
            ),
            $this->getValidationDecorator()->notRequiredParamRule(
                new ParamRule(
                    self::PARAMETER_DESCRIPTION,
                    new Rule(Rules::STRING_TYPE),
                    new Rule(Rules::LENGTH, [null, self::PARAM_RULE_DESCRIPTION_MAX_LENGTH]),
                ),
                true
            ),
            $this->getValidationDecorator()->notRequiredParamRule(
                new ParamRule(
                    self::PARAMETER_NOTE,
                    new Rule(Rules::STRING_TYPE),
                    new Rule(Rules::LENGTH, [null, self::PARAM_RULE_NOTE_MAX_LENGTH]),
                ),
                true
            ),
        ];
    }

    /**
     * @return EntityUniquePropertyOption
     */
    private function getPositionCommonUniqueOption(): EntityUniquePropertyOption
    {
        $uniqueOption = new EntityUniquePropertyOption();
        $uniqueOption->setIgnoreValues([
            'isDeleted' => true
        ]);
        return $uniqueOption;
    }

    /**
     * @inheritDoc
     */
    public function update(): EndpointResult
    {
        $id = $this->getRequestParams()->getInt(RequestParams::PARAM_TYPE_ATTRIBUTE, CommonParams::PARAMETER_ID);

        $position = $this->getPositionService()->getPositionById($id);
        $this->throwRecordNotFoundExceptionIfNotExist($position, Position::class);
        $this->setPosition($position);
        $this->getPositionService()->savePosition($position);

        return new EndpointResourceResult(PositionModel::class, $position);
    }

    /**
     * @inheritDoc
     */
    public function getValidationRuleForUpdate(): ParamRuleCollection
    {
        $uniqueOption = $this->getPositionCommonUniqueOption();
        $uniqueOption->setIgnoreId($this->getAttributeId());

        return new ParamRuleCollection(
            new ParamRule(
                CommonParams::PARAMETER_ID,
                new Rule(Rules::POSITIVE)
            ),
            ...$this->getCommonBodyValidationRules($uniqueOption),
        );
    }

    /**
     * @inheritDoc
     */
    public function delete(): EndpointResult
    {
        $ids = $this->getPositionService()->getPositionDao()->getExistingPositionIds(
            $this->getRequestParams()->getArray(RequestParams::PARAM_TYPE_BODY, CommonParams::PARAMETER_IDS)
        );
        $this->throwRecordNotFoundExceptionIfEmptyIds($ids);
        $this->getPositionService()->deletePosition($ids);
        return new EndpointResourceResult(ArrayModel::class, $ids);
    }

    /**
     * @inheritDoc
     */
    public function getValidationRuleForDelete(): ParamRuleCollection
    {
        return new ParamRuleCollection(
            new ParamRule(CommonParams::PARAMETER_IDS),
        );
    }
}

