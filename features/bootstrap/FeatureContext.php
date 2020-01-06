<?php

use Behat\Behat\Context\Context;
use Behat\Behat\Context\SnippetAcceptingContext;
use Behat\Gherkin\Node\PyStringNode;
use Behat\Gherkin\Node\TableNode;
use Symfony\Component\Process\Process;

/**
 * Defines application features from the specific context.
 */
class FeatureContext implements Context, SnippetAcceptingContext
{
    /**
     * Path to fixtures.
     */
    public const FIXTURES = __DIR__ . '/../../fixtures/';

    /**
     * Docker image name to use.
     */
    public const IMAGE = 'test';

    /**
     * @var string the fixture to run within.
     */
    protected $fixture = 'empty';

    /**
     * @var \Symfony\Component\Process\Process the docker process.
     */
    protected $process;

    /**
     * Initializes context.
     *
     * Every scenario gets its own context instance.
     * You can also pass arbitrary arguments to the
     * context constructor through behat.yml.
     */
    public function __construct()
    {
    }

    /**
     * @BeforeSuite
     */
    public static function buildImage()
    {
        $process = new Process(['docker', 'build', '.', '-t', self::IMAGE]);
        $process->mustRun();
    }

    /**
     * @Given the fixture :fixture
     */
    public function theFixture($fixture)
    {
        if (!file_exists(self::FIXTURES . $fixture)) {
            throw new \RuntimeException('Unknown fixture ' . self::FIXTURES . $fixture);
        }

        $this->fixture = $fixture;
    }

    /**
     * @When running
     */
    public function running()
    {
        $this->process = new Process([
            'docker',
            'run',
            '--rm',
            '-v',
            self::FIXTURES . $this->fixture . ':/workspace',
            '-w',
            '/workspace',
            self::IMAGE,
            // Use dry-run.
            '--dry-run',
        ]);

        $this->process->setTimeout(300);
        $this->process->mustRun();
    }

    /**
     * @Then it should succeed with output containing:
     */
    public function itShouldSucceedWithOutputContaining(PyStringNode $string)
    {
        if (!$this->process) {
            throw new \RuntimeException('No process was run');
        }

        if (!$this->process->isSuccessful()) {
            echo($this->process->getErrorOutput());
            throw new \RuntimeException('Process exited with an error');
        }

        $output = $this->process->getOutput();
        if (strpos($output, (string) $string) === false) {
            throw new \RuntimeException(sprintf('Output "%s" does not contain "%s"', $output, $string));
        }
    }
}
