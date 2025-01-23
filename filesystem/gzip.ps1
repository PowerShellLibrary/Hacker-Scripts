function ConvertFrom-Gzip {
    Param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [ValidateScript( { (Get-Item $_).Name.EndsWith(".gz") })]
        [System.IO.FileInfo]
        $InputObject,

        [Parameter(Mandatory = $false)]
        [switch]
        $RemoveInputFile
    )
    Process {
        # Create a new file and open a filestream for it
        $NewFilename = $InputObject.FullName.Remove($InputObject.FullName.Length - $InputObject.Extension.Length)
        $DecompressedFileStream = [System.IO.File]::Create($NewFilename)

        # Open the compressed file and copy the file to the decompressed stream
        $CompressedFileStream = $InputObject.OpenRead()
        $GZipStream = [System.IO.Compression.GZipStream]::new($CompressedFileStream, [System.IO.Compression.CompressionMode]::Decompress)
        $GZipStream.CopyTo($DecompressedFileStream)

        # Cleanup
        $DecompressedFileStream.Dispose()
        $GZipStream.Dispose()
        $CompressedFileStream.Dispose()
        $DecompressedFileStream, $GZipStream, $CompressedFileStream = $null

        # Remove the initial file if requested.
        if ($PSBoundParameters.ContainsKey('RemoveInputFile')) {
            $InputObject.Delete()
        }
    }
}