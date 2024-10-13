<?php
declare(strict_types=1);

namespace App\Domain\Service;

use App\Domain\Model\Token;
use App\Domain\Repository\TokenRepositoryInterface;

final class TokenManager
{
    public function __construct(private TokenRepositoryInterface $tokenRepository)
    {
        $this->tokenRepository = $tokenRepository;
    }

    public function retrieveToken(string $clientId, string $clientSecret, string $scope): Token
    {
        return $this->tokenRepository->getToken($clientId, $clientSecret, $scope);
    }
}
