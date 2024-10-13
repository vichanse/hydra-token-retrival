<?php
declare(strict_types=1);

namespace App\Infrastructure\Http;

use Symfony\Contracts\HttpClient\HttpClientInterface;
use App\Domain\Model\Token;
use App\Domain\Repository\TokenRepositoryInterface;
use Symfony\Component\DependencyInjection\Attribute\Autowire;

class HydraTokenRepository implements TokenRepositoryInterface
{

    public function __construct(
        private readonly HttpClientInterface $httpClient, 
        #[Autowire(env: 'HYDRA_TOKEN_URL')]
        private readonly string $hydraTokenUrl)
    {

    }

    public function getToken(string $clientId, string $clientSecret, string $scope): Token
    {
        $response = $this->httpClient->request('POST', $this->hydraTokenUrl, [
            
            'body' => [
                'grant_type' => 'client_credentials',
                'client_id' => $clientId,
                'client_secret' => $clientSecret,
                'scope' => '',
            ],
        ]);
    
        $data = $response->toArray();

        return new Token($data['access_token'], $data['expires_in'], $data['token_type']); 
    }
}
