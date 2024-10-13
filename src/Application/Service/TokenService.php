<?php
declare(strict_types=1);

namespace App\Application\Service;

use App\Application\Dto\TokenRequestDTO;
use App\Domain\Service\TokenManager;
use App\Domain\Model\Token;

class TokenService
{
    public function __construct(private readonly TokenManager $tokenManager)
    {
    }

    public function retrieveToken(TokenRequestDTO $tokenRequest): Token
    {
        return $this->tokenManager->retrieveToken(
            $tokenRequest->clientId,
            $tokenRequest->clientSecret,
            $tokenRequest->scope
        );
    }
}
