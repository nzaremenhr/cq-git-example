nextflow.enable.dsl=2

process downloadFile {
publishDir "/home/narges/cq-git-example/work" , mode: "copy", overwrite: true
output:
path "batch1.fasta"
"""
wget https://tinyurl.com/cqbatch1 -O batch1.fasta
"""
}

workflow {
downloadFile()
}