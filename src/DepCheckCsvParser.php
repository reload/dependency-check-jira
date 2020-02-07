<?php

declare(strict_types=1);

namespace DependencyCheckJira;

use RuntimeException;

class DepCheckCsvParser
{
    /**
     * Maps our field names to the CSV columns.
     */
    public const FIELDS = [
        'name' => 'DependencyName',
        'path' => 'DependencyPath',
        'cve' => 'CVE',
        'description' => 'Vulnerability',
    ];

    /**
     * The file to parse.
     *
     * @var string
     */
    protected $filename;

    public function __construct(string $filename)
    {
        $this->filename = $filename;
    }

    /**
     * @return array<array<string, string>>
     */
    public function getCves(): array
    {
        $data = [];
        $fh = \fopen($this->filename, "r");

        if (!$fh) {
            throw new RuntimeException("Cannot open file");
        }

        while ($row = \fgetcsv($fh)) {
            $data[] = $row;
        }

        /** @var array<string> $header */
        $header = \array_shift($data);
        $fields = $this->getFieldIndexes($header);

        $cves = [];

        foreach ($data as $row) {
            $cvs = [];

            foreach ($fields as $name => $index) {
                $cvs[$name] = $row[$index];
            }

            $cves[] = $cvs;
        }

        return $cves;
    }

    /**
     * Return the numeric indexes of the fields we use.
     *
     * @param array<string> $header
     *   The CSV header.
     *
     * @return array<string, int>
     */
    public function getFieldIndexes(array $header): array
    {
        $mapping = [];

        foreach (self::FIELDS as $name => $csvName) {
            $index = \array_search($csvName, $header);

            if ($index === false) {
                throw new RuntimeException($csvName . ' column not found in CSV');
            }

            $mapping[$name] = \intval($index);
        }

        return $mapping;
    }
}
