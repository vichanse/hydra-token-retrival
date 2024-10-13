<?php
declare(strict_types=1);

namespace App\Domain\Model;

final class Token
{

    public function __construct(public readonly string $accessToken, public readonly int $expiresIn, public readonly string $tokenType)
    {

    }
}
