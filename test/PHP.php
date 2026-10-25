<?php

namespace App\Models;

// use Illuminate\Contracts\Auth\MustVerifyEmail;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;

class User extends Authenticatable
{
    use HasFactory, Notifiable;

    /**
     * The attributes that are mass assignable.
     *
     * @var array<int, string>
     */
    protected $fillable = [
        'name',
        'email',
        'password',
    ];

    /**
     * The attributes that should be hidden for serialization.
     *
     * @var array<int, string>
     */
    protected $hidden = [
        'password',
        'remember_token',
    ];

    /**
     * Get the attributes that should be cast.
     *
     * @return array<string, string>
     */
    protected function casts(): array
    {
        return [
            'email_verified_at' => 'datetime',
            'password' => 'hashed',
        ];
    }
}

Artisan::command('inspire', function () {
  $this->comment(Inspiring::quote());
})->purpose('Display an inspiring quote')->hourly();


use function PHPStan\Testing\assertType;

/** @var Repository $cache */
$cache = resolve(Repository::class);

assertType('mixed', $cache->get('key'));
$table->property;


class BusBatchTest extends TestCase
{
    protected function setUp(): void
    {
        $db = new DB;

        $db->addConnection([
            'driver' => 'sqlite',
            'database' => ':memory:',
        ]);

        $db->bootEloquent();
        $db->setAsGlobal();

        $this->createSchema();

        $_SERVER['__finally.count'] = 0;
        $_SERVER['__progress.count'] = 0;
        $_SERVER['__then.count'] = 0;
        $_SERVER['__catch.count'] = 0;
    }

    /**
     * Setup the database schema.
     *
     * @return void
     */
    public function createSchema(array $a)
    {
        $this->schema()->create('job_batches', function ($table) {
            $table->string('id')->primary();
            $table->string('name');
            $table->integer('total_jobs');
            $table->integer('pending_jobs');
            $table->integer('failed_jobs');
            $table->text('failed_job_ids');
            $table->text('options')->nullable();
            $table->integer('cancelled_at')->nullable();
            $table->integer('created_at');
            $table->integer('finished_at')->nullable();
        });
    }

    /**
     * Tear down the database schema.
     *
     * @return void
     */
    protected function tearDown(): void
    {
        unset($_SERVER['__finally.batch'], $_SERVER['__progress.batch'], $_SERVER['__then.batch'], $_SERVER['__catch.batch'], $_SERVER['__catch.exception']);

        $this->schema()->drop('job_batches');

        m::close();
        return null;
    }

    public function test_jobs_can_be_added_to_the_batch(MyClass $param): Factory
    {
        $queue = m::mock(Factory::class);

        $batch = $this->createTestBatch($queue);

        $job = new class
        {
            use Batchable;
        };

        $secondJob = new class
        {
            use Batchable;
        };

        $thirdJob = function () {
        };

        $queue->shouldReceive('connection')->once()
                        ->with('test-connection')
                        ->andReturn($connection = m::mock(stdClass::class));

        $connection->shouldReceive('bulk')->once()->with(m::on(function ($args) use ($job, $secondJob) {
            return
                $args[0] == $job &&
                $args[1] == $secondJob &&
                $args[2] instanceof CallQueuedClosure
                && is_string($args[2]->batchId);
        }), '', 'test-queue');

        $batch = $batch->add([$job, $secondJob, $thirdJob]);

        $this->assertEquals(3, $batch->totalJobs);
        $this->assertEquals(3, $batch->pendingJobs);
        $this->assertIsString($job->batchId);
        $this->assertInstanceOf(CarbonImmutable::class, $batch->createdAt);
    }
  }

// --- Additional syntax coverage -------------------------------------------

namespace App\Jobs;

declare(ticks=1);

use App\Models\{User, Post as Article};
use Illuminate\Support\Collection;
use function strlen, array_map as map, sprintf;
use const PHP_EOL, JSON_PRETTY_PRINT as PRETTY;

const MAX_ATTEMPTS = 1_000;
define('LEGACY_FLAG', 0b1010_0101);

#[\Attribute(\Attribute::TARGET_METHOD | \Attribute::IS_REPEATABLE)]
final class Route
{
    public function __construct(
        public readonly string $path,
        public readonly array $methods = ['GET'],
        public ?string $name = null,
    ) {
    }
}

enum Priority: int implements \JsonSerializable
{
    case Low = 10;
    case Normal = 20;
    case High = 30;

    public static function fromLabel(string $label): static
    {
        return match (strtolower($label)) {
            'low', 'minor' => self::Low,
            'high', 'urgent' => self::High,
            default => self::Normal,
        };
    }

    public function label(): string
    {
        return ucfirst(strtolower($this->name));
    }

    public function jsonSerialize(): mixed
    {
        return $this->value;
    }
}

enum Status
{
    case Pending;
    case Done;
}

interface Dispatchable
{
    public const QUEUE = 'default';

    public function handle(mixed ...$args): int|string|null;
}

interface Retryable
{
    public function retries(): int;
}

trait Loggable
{
    protected static int $logged = 0;
    abstract protected function logChannel(): string;

    public function log(string $message, string|\Stringable ...$context): void
    {
        static::$logged++;
        fprintf(STDERR, "[%s] %s %s" . PHP_EOL, $this->logChannel(), $message, implode(' ', $context));
    }
}

abstract class Job implements Dispatchable, Retryable
{
    use Loggable {
        log as protected traitLog;
    }

    public const DEFAULT_PRIORITY = Priority::Normal;
    protected static ?self $last = null;
    private array $meta = [];

    public function __construct(
        protected readonly string $id,
        private Priority $priority = self::DEFAULT_PRIORITY,
        protected Status $status = Status::Pending,
        protected (Collection&\Countable)|null $payload = null,
    ) {
        self::$last = $this;
    }

    abstract public function run(): int;

    public function fail(string $reason = 'unknown'): never
    {
        throw new \LogicException($reason);
    }

    public function retries(): int
    {
        return 3;
    }

    protected function logChannel(): string
    {
        return static::class;
    }

    public function __get(string $name): mixed
    {
        return $this->meta[$name] ?? null;
    }

    public function __set(string $name, mixed $value): void
    {
        $this->meta[$name] = $value;
    }

    public function __isset(string $name): bool
    {
        return isset($this->meta[$name]);
    }

    public function __call(string $method, array $arguments): mixed
    {
        return $this->{"on" . ucfirst($method)}(...$arguments);
    }

    public static function __callStatic(string $method, array $arguments): static
    {
        return new static(...$arguments);
    }

    public function __invoke(int $times = 1): \Generator
    {
        for ($i = 0; $i < $times; $i++) {
            yield $i => $this->id;
        }
        yield from $this->tail();
        return $times;
    }

    public function __toString(): string
    {
        return sprintf('%s#%s(%d)', __CLASS__, $this->id, $this->priority->value);
    }

    private function tail(): iterable
    {
        yield 'tail';
    }

    public function withPriority(Priority $priority): static
    {
        $clone = clone $this;
        $clone->priority = $priority;
        return $clone;
    }
}

final class SyncUsersJob extends Job
{
    public const string VERSION = '2.1';

    #[Route('/sync', methods: ['POST'], name: 'sync')]
    #[Route(path: '/resync')]
    public function run(): int
    {
        $users = [['id' => 1, 'tags' => ['a', 'b']], ['id' => 2, 'tags' => []]];
        [$first, ['tags' => [, $second]]] = $users;
        ['id' => $id, 'tags' => $tags] = $first;
        list($a, list($b)) = [1, [2]];
        $count = 0;
        $attempts = 0;

        retry:
        $attempts++;
        try {
            foreach ($users as $index => ['id' => $uid, 'tags' => &$userTags]) {
                $userTags[] = "u{$uid}";
                $count += count($userTags) <=> 1;
            }
            unset($userTags);
            if ($attempts < 2) {
                throw new \RuntimeException("attempt $attempts");
            }
        } catch (\RuntimeException | \LogicException $e) {
            $this->log($e->getMessage(), $e::class);
            goto retry;
        } finally {
            $this->attempts = $attempts;
        }

        $label = match (true) {
            $count > 10 => 'many',
            $count > 0 => 'some',
            default => 'none',
        };

        $len = strlen(...);
        $mapper = $this->tail(...);
        $double = static fn(int $n): int => $n * 2;
        $acc = 0;
        $adder = function (int $n) use (&$acc): int {
            return $acc += $n;
        };
        $nullsafe = self::$last?->withPriority(Priority::High)?->priority?->label();
        $coalesced = $this->missing ?? $nullsafe ?? throw new \DomainException('no value');
        $this->meta ??= [];
        $this->$label = $double($len($label));
        $varName = 'label';
        $$varName = 'rebound';
        $spread = [...$tags, ...array_values($users), 'key' => $id];
        $named = sprintf(format: '%05.2f %x %o %b %e', values: 3.14159, 0x1F, 0o17, 0b11, 1.5e3);

        switch ($this->status) {
            case Status::Pending:
                $count++;
                // fallthrough
            case Status::Done:
                break;
            default:
                return $count;
        }

        $i = 10;
        do {
            $i--;
            if ($i % 2 === 0) {
                continue;
            }
        } while ($i > 0);
        while ($i < 5):
            $i++;
        endwhile;
        foreach ($users as $user):
            static $seen = 0;
            $seen++;
        endforeach;
        if ($this instanceof Dispatchable && !($this instanceof \Throwable)):
            $count += (int) $this->payload?->count();
        elseif ($this->payload === null):
            $count -= 1;
        else:
            $count *= 2;
        endif;

        $heredoc = <<<TEXT
            Job {$this->id} ran {$count} times for {$users[0]['id']}
            escaped \$dollar \t tab \u{1F600} \x41 \101
            TEXT;
        $nowdoc = <<<'TEXT'
            Raw {$not} interpolated \n
            TEXT;
        $mixed = 'single \'quoted\' \n' . "double \"quoted\" $id {$spread['key']} ${varName}" . PHP_EOL;
        $json = json_encode(compact('label', 'count', 'spread'), PRETTY | JSON_THROW_ON_ERROR);
        $filtered = array_filter(map(fn($u) => $u['id'] ?? 0, $users), static fn(int $v): bool => $v > 0);
        $types = [is_int($count), is_string($label), is_array($spread), is_null($nullsafe), is_callable($len), gettype(1.5), (string) 1e3, (bool) '0', (float) '1.25', intdiv(7, 2), 7 % 3, 2 ** 10, PHP_INT_MAX, M_PI, null, true, FALSE];
        $generator = $this(3);
        foreach ($generator as $k => $v) {
            echo $k, ' => ', $v, "\n";
        }
        return $generator->getReturn() + $adder(1) + array_sum($filtered);
    }
}

function &refProvider(array &$store, int|float $key = 0, ?callable $cb = null): ?array
{
    global $argv;
    $store[$key] ??= $cb ? $cb($key) : null;
    return $store;
}

$job = SyncUsersJob::make('job-1', priority: Priority::fromLabel('urgent'));
$job->log('started', 'ctx', new \DateTimeImmutable());
print($job . "\n");
echo (string) $job, PHP_EOL;
exit($job->run() > 0 ? 0 : 1);
?>
<ul>
  <?php foreach ([1, 2] as $n): ?>
    <li><?= $n ?></li>
  <?php endforeach; ?>
</ul>
<?php
// trailing comment
