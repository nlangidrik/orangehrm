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

namespace OrangeHRM\Admin\Controller\File;

use OrangeHRM\Core\Controller\AbstractFileController;
use OrangeHRM\Framework\Http\Request;
use OrangeHRM\Framework\Http\Response;

class JobTitleCsvImportSampleAttachmentController extends AbstractFileController
{
    /**
     * @param Request $request
     * @return Response
     */
    public function handle(Request $request): Response
    {
        $response = $this->getResponse();
        $content = "job_title,job_description,note";
        $this->setCommonHeadersToResponse(
            'jobTitleImportData.csv',
            'application/csv',
            strlen($content),
            $response
        );
        $response->setContent($content);
        return $response;
    }
}

