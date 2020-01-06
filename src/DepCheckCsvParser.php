<?php

declare(strict_types=1);

namespace DependencyCheckJira;

class DepCheckCsvParser
{
    /**
     * Maps our field names to the CSV columns.
     */
    public const FIELDS = ['name' => 'DependencyName', 'path' => 'DependencyPath', 'cve' => 'CVE', 'description' => 'Vulnerability'];

    /**
     * @var string the file to parse.
     */
    protected $filename;

    public function __construct(string $filename)
    {
        $this->filename = $filename;
    }

    public function getCves(): array
    {
        $data = [];
        $fh = fopen($this->filename, "r");
        while (($row = fgetcsv($fh)) !== false) {
            $data[] = $row;
        }

        $header = array_shift($data);
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
            $index = array_search($csvName, $header);

            if ($index === false) {
                throw new \RuntimeException($csvName . ' column not found in CSV');
            }

            $mapping[$name] = $index;
        }

        return $mapping;
    }
}
