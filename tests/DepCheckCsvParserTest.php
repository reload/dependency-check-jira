<?php

declare(strict_types=1);

namespace DependencyCheckJira;

use PHPUnit\Framework\TestCase;
use RuntimeException;

class DepCheckCsvParserTest extends TestCase
{
    public function testParsing(): void
    {
        $parser = new DepCheckCsvParser(__DIR__ . '/../fixtures/csv/dependency-check-report.csv');

        $expected = [
            [
                'name' => 'Folly:2018.10.22.00',
                'path' => '/workspace/Folly.podspec',
                'cve' => 'CVE-2008-0660',
                // phpcs:ignore Generic.Files.LineLength
                'description' => 'Multiple stack-based buffer overflows in Aurigma Image Uploader ActiveX control (ImageUploader4.ocx) 4.6.17.0, 4.5.70.0, and 4.5.126.0, and ImageUploader5 5.0.10.0, as used by Facebook PhotoUploader 4.5.57.0, allow remote attackers to execute arbitrary code via long (1) ExtractExif and (2) ExtractIptc properties.',
            ],
            [
                'name' => 'Folly:2018.10.22.00',
                'path' => '/workspace/Folly.podspec',
                'cve' => 'CVE-2019-11934',
                // phpcs:ignore Generic.Files.LineLength
                'description' => 'Improper handling of close_notify alerts can result in an out-of-bounds read in AsyncSSLSocket. This issue affects folly prior to v2019.11.04.00.',
            ],
        ];
        $this->assertEquals($expected, $parser->getCves());
    }

    /**
     * Test header mapping.
     */
    public function testHeaderMapping(): void
    {
        $parser = new DepCheckCsvParser(__DIR__ . '/../fixtures/csv/dependency-check-report.csv');

        $this->assertEquals(
            ['name' => 0, 'path' => 4,'cve' => 1, 'description' => 3],
            $parser->getFieldIndexes(['DependencyName', 'CVE', 'Banana', 'Vulnerability', 'DependencyPath']),
        );

        $this->assertEquals(
            ['name' => 1, 'path' => 4, 'cve' => 3, 'description' => 0],
            $parser->getFieldIndexes(['Vulnerability', 'DependencyName', 'Banana', 'CVE', 'DependencyPath']),
        );
    }

    /**
     * Test that getFieldIndexes throws error on missing columns.
     */
    public function testHeaderMappingError(): void
    {
        $parser = new DepCheckCsvParser(__DIR__ . '/../fixtures/csv/dependency-check-report.csv');

        $this->expectException(RuntimeException::class);

        $parser->getFieldIndexes(['DependencyName', 'Banana', 'Vulnerability']);
    }
}
