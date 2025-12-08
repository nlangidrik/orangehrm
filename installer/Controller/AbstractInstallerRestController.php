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

namespace OrangeHRM\Installer\Controller;

use OrangeHRM\Framework\Http\Request;
use OrangeHRM\Framework\Http\Response;
use OrangeHRM\Installer\Exception\MigrationException;
use OrangeHRM\Installer\Exception\NotImplementedException;
use OrangeHRM\Installer\Util\Logger;
use Throwable;

abstract class AbstractInstallerRestController extends AbstractInstallerController
{
    /**
     * @param Request $request
     * @return Response
     * @throws NotImplementedException
     */
    protected function execute(Request $request): Response
    {
        // 'application/json', 'application/x-json'
        if ($request->getContentType() === 'json') {
            if ($request->getContent() !== '') {
                $data = json_decode($request->getContent(), true);
                if (is_array($data)) {
                    $request->request->add($data);
                }
            }
        }

        $response = $this->getResponse();
        $response->headers->set('Content-Type', 'application/json');
        $data = [];
        try {
            switch ($request->getMethod()) {
                case Request::METHOD_GET:
                    $data = $this->handleGet($request);
                    break;

                case Request::METHOD_POST:
                    $data = $this->handlePost($request);
                    break;

                case Request::METHOD_PUT:
                    $data = $this->handlePut($request);
                    break;

                case Request::METHOD_DELETE:
                    $data = $this->handleDelete($request);
                    break;

                default:
                    throw new NotImplementedException();
            }
        } catch (NotImplementedException $e) {
            $response->setStatusCode(Response::HTTP_NOT_IMPLEMENTED);
            $response->setContent(
                json_encode([
                    'error' => [
                        'status' => $response->getStatusCode(),
                        'message' => $e->getMessage(),
                    ]
                ])
            );
            return $response;
        } catch (MigrationException $e) {
            $response->setStatusCode(Response::HTTP_REQUEST_TIMEOUT);
            $response->setContent(
                json_encode([
                    'error' => [
                        'status' => $response->getStatusCode(),
                        'message' => $e->getMessage()
                    ]
                ])
            );
            Logger::getLogger()->error($e->getMessage());
            Logger::getLogger()->error($e->getTraceAsString());
            return $response;
        } catch (Throwable $e) {
            $response->setStatusCode(Response::HTTP_INTERNAL_SERVER_ERROR);
            $errorMessage = $e->getMessage();
            $errorClass = get_class($e);
            
            // Log full error details
            Logger::getLogger()->error("Error in " . get_class($this) . ": $errorClass");
            Logger::getLogger()->error("Message: $errorMessage");
            Logger::getLogger()->error("File: " . $e->getFile() . ":" . $e->getLine());
            Logger::getLogger()->error("Trace: " . $e->getTraceAsString());
            
            // Provide more helpful error message for common issues
            if (strpos($errorMessage, 'memory') !== false || strpos($errorMessage, 'Memory') !== false) {
                $errorMessage = 'Insufficient memory. Please increase PHP memory_limit.';
            } elseif (strpos($errorMessage, 'timeout') !== false || strpos($errorMessage, 'Timeout') !== false || strpos($errorMessage, 'execution time') !== false) {
                $errorMessage = 'Execution timeout. Please increase PHP max_execution_time.';
            } elseif (strpos($errorMessage, 'SQL') !== false || strpos($errorMessage, 'database') !== false || strpos($errorMessage, 'Database') !== false) {
                $errorMessage = 'Database error: ' . $errorMessage;
            } elseif (strpos($errorMessage, 'Connection') !== false || strpos($errorMessage, 'connection') !== false) {
                $errorMessage = 'Database connection error. Please check your database configuration.';
            }
            
            $response->setContent(
                json_encode([
                    'error' => [
                        'status' => $response->getStatusCode(),
                        'message' => $errorMessage,
                        'type' => $errorClass,
                    ]
                ])
            );
            return $response;
        }
        $response->setContent(json_encode($data));
        return $response;
    }

    /**
     * @param Request $request
     * @return array
     * @throws NotImplementedException
     */
    protected function handleGet(Request $request): array
    {
        throw new NotImplementedException();
    }

    /**
     * @param Request $request
     * @return array
     * @throws NotImplementedException
     */
    protected function handlePost(Request $request): array
    {
        throw new NotImplementedException();
    }

    /**
     * @param Request $request
     * @return array
     * @throws NotImplementedException
     */
    protected function handlePut(Request $request): array
    {
        throw new NotImplementedException();
    }

    /**
     * @param Request $request
     * @return array
     * @throws NotImplementedException
     */
    protected function handleDelete(Request $request): array
    {
        throw new NotImplementedException();
    }
}
