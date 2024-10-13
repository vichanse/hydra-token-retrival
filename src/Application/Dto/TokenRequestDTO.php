<?php 
declare(strict_types=1);

namespace App\Application\Dto;

final class TokenRequestDTO
{
    public function __construct(public string $clientId,public string $clientSecret, public string $scope)
    {
    }
}
