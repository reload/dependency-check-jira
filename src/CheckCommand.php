<?php

declare(strict_types=1);

namespace DependencyCheckJira;

use Symfony\Component\Console\Command\Command;
use Symfony\Component\Console\Input\InputInterface;
use Symfony\Component\Console\Input\InputOption;
use Symfony\Component\Console\Output\OutputInterface;
use Symfony\Component\Process\Process;

class CheckCommand extends Command
{
    /**
     * Name of the command.
     *
     * @var string
     */
    protected static $defaultName = 'check';

    /**
     * {@inheritDoc}
     */
    protected function configure()
    {
        $this
            ->setDescription('Create Jira tickets for CVEs found by dependency-check.')
            ->setHelp('Run dependency-check and create Jira issues for new CVEs found.')
            ->addOption(
                'dry-run',
                null,
                InputOption::VALUE_NONE,
                'Do dry run (dont change anything)',
            );
    }

    /**
     * {@inheritDoc}
     */
    protected function execute(InputInterface $input, OutputInterface $output)
    {
        $checkdep = new Process([
            '/opt/dependency-check/bin/dependency-check.sh',
            // Scan current directory.
            '-s',
            '.',
            // Enable experimental analyzers, so we'll get the cocopod analyzer.
            '--enableExperimental',
            // Log to /tmp.
            '-l',
            '/tmp/log',
            // Place output in /tmp.
            '--out',
            '/tmp',
            // Use CSV format.
            '--format',
            'CSV',
            // Disable the analyzers we don't need to speed things up.
            '--disableArchive',
            '--disableAssembly',
            '--disableAutoconf',
            '--disableBundleAudit',
            '--disableCentral',
            '--disableCentralCache',
            '--disableCmake',
            '--disableComposer',
            '--disableGolangDep',
            '--disableGolangMod',
            '--disableJar',
            '--disableNodeAudit',
            '--disableNodeAuditCache',
            '--disableNodeJS',
            '--disableNugetconf',
            '--disableNuspec',
            '--disableOpenSSL',
            '--disableOssIndex',
            '--disableOssIndexCache',
            '--disablePyDist',
            '--disablePyPkg',
            '--disableRetireJS',
            '--disableRubygems',
            '--disableSwiftPackageManagerAnalyzer',
        ]);

        $checkdep->setTimeout(0);
        $output->writeln('Running dependency-checker');
        $checkdep->mustRun();
        $output->writeln('Done');

        $outfile = '/tmp/dependency-check-report.csv';

        if (!\file_exists($outfile)) {
            throw new \RuntimeException('Error running dependency-checker');
        }

        $parser = new DepCheckCsvParser($outfile);

        foreach ($parser->getCves() as $csv) {
            $output->writeln(sprintf("Detected %s on package %s in %s", $csv['cve'], $csv['name'], $csv['path']));
        }
    }
}
