<?php
declare(strict_types=1);

namespace App\Domain\Repository;

use App\Domain\Model\Token;

interface TokenRepositoryInterface
{
    public function getToken(string $clientId, string $clientSecret, string $scope): Token;
}