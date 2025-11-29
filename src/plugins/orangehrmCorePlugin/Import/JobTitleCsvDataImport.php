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

namespace OrangeHRM\Core\Import;

use OrangeHRM\Admin\Service\JobTitleService;
use OrangeHRM\Core\Traits\LoggerTrait;
use OrangeHRM\Core\Traits\Service\TextHelperTrait;
use OrangeHRM\Core\Traits\ServiceContainerTrait;
use OrangeHRM\Entity\JobTitle;

class JobTitleCsvDataImport extends CsvDataImport
{
    use ServiceContainerTrait;
    use LoggerTrait;
    use TextHelperTrait;

    /**
     * @var null|JobTitleService
     */
    protected ?JobTitleService $jobTitleService = null;

    /**
     * @param array $data
     * @return bool
     */
    public function import(array $data): bool
    {
        // CSV format: job_title, job_description, note
        $jobTitleName = $data[0] ?? null;
        $jobDescription = $data[1] ?? null;
        $note = $data[2] ?? null;

        // Validate required field
        if ($this->isEmpty($jobTitleName)) {
            $this->getLogger()->warning('Job title name is required');
            return false;
        }

        // Check length constraints
        if ($this->getTextHelper()->strLength($jobTitleName) > 100) {
            $this->getLogger()->warning('Job title name exceeds maximum length of 100 characters');
            return false;
        }

        // Check if job title already exists (case-insensitive)
        if (!$this->isUniqueJobTitleName($jobTitleName)) {
            $this->getLogger()->warning('Job title record not imported due to duplicated job title name: ' . $jobTitleName);
            return false;
        }

        // Validate optional fields length
        if ($jobDescription !== null && $this->getTextHelper()->strLength($jobDescription) > 400) {
            $this->getLogger()->warning('Job description exceeds maximum length of 400 characters');
            return false;
        }

        if ($note !== null && $this->getTextHelper()->strLength($note) > 400) {
            $this->getLogger()->warning('Note exceeds maximum length of 400 characters');
            return false;
        }

        // Create and save job title
        $jobTitle = new JobTitle();
        $jobTitle->setJobTitleName(trim($jobTitleName));
        if (!$this->isEmpty($jobDescription)) {
            $jobTitle->setJobDescription(trim($jobDescription));
        }
        if (!$this->isEmpty($note)) {
            $jobTitle->setNote(trim($note));
        }
        $jobTitle->setIsDeleted(JobTitle::ACTIVE);

        $this->getJobTitleService()->saveJobTitle($jobTitle);
        return true;
    }

    /**
     * @return JobTitleService
     */
    public function getJobTitleService(): JobTitleService
    {
        return $this->jobTitleService ??= new JobTitleService();
    }

    /**
     * @param JobTitleService $jobTitleService
     */
    public function setJobTitleService(JobTitleService $jobTitleService): void
    {
        $this->jobTitleService = $jobTitleService;
    }

    /**
     * @param string|null $jobTitleName
     * @return bool
     */
    private function isUniqueJobTitleName(?string $jobTitleName): bool
    {
        if ($this->isEmpty($jobTitleName)) {
            return false;
        }

        $jobTitleList = $this->getJobTitleService()->getJobTitleList(false);
        foreach ($jobTitleList as $existingJobTitle) {
            if (strcasecmp($existingJobTitle->getJobTitleName(), trim($jobTitleName)) === 0) {
                return false;
            }
        }
        return true;
    }

    /**
     * @param string|null $string
     * @return bool
     */
    private function isEmpty(?string $string): bool
    {
        return $string === null || trim($string) === '';
    }
}

