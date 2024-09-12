nextflow.enable.dsl = 2

params.storeDir="${launchDir}/cache"
params.publishDir="${launchDir}/publish"
params.accession= "SRR16641606"

process prefetch {
  storeDir params.storeDir
  container "https://depot.galaxyproject.org/singularity/sra-tools%3A2.11.0--pl5321ha49a11a_3"
  input:
    val accession
  output:
    path "${accession}"
  script:
  """
  prefetch $accession
  """
}

process convert_to_fastq {
  storeDir params.storeDir
  publishDir params.publishDir, mode:"copy", overwrite:true
  container "https://depot.galaxyproject.org/singularity/sra-tools%3A2.11.0--pl5321ha49a11a_3"
  input:
   path accession
  output:
    path "${accession}.fastq"
  script:
  """
  fastq-dump $accession
  """
}


process generateStats {

publishDir params.publishDir, mode:"copy" , overwrite: true
container "https://depot.galaxyproject.org/singularity/ngsutils%3A0.5.9--py27h9801fc8_5"
input:
     path accession
  output:
    path "*"
  script:
  """
 fastqutils stats $accession > ${accession}.stats
  """



}
workflow {
  variable=prefetch(Channel.from(params.accession))
  convert=convert_to_fastq(variable)
  stats=generateStats(convert)
   
}