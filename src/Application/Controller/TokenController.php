<?php
declare(strict_types=1);

namespace App\Application\Controller;

use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\HttpFoundation\JsonResponse;
use App\Application\Dto\TokenRequestDTO;
use App\Application\Service\TokenService;
use Symfony\Component\Routing\Attribute\Route;

class TokenController extends AbstractController
{

    public function __construct(private readonly TokenService $tokenService)
    {
    }

    #[Route(path: "/token", methods:['GET'])]
    public function __invoke(): JsonResponse
    {
        $clientId = $this->getParameter('oauth2_client_id');
        $clientSecret = $this->getParameter('oauth2_client_secret');
        $scope = 'openid profile email';

        $tokenRequest = new TokenRequestDTO($clientId, $clientSecret, $scope);
        $token = $this->tokenService->retrieveToken($tokenRequest);

        return new JsonResponse([
            'access_token' => $token->accessToken,
            'expires_in' => $token->expiresIn,
            'token_type' => $token->tokenType
        ]);
    }
}
