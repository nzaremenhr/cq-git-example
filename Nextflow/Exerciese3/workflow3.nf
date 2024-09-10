nextflow.enable.dsl=2

params.out = "$launchDir/output"
params.url = "https://gitlab.com/dabrowskiw/cq-examples/-/raw/master/data/sequences.sam?inline=false"
params.store = "$launchDir/datastore"
params.temp ="$launchDir/downloads"

///In many web services, like GitLab or GitHub, query parameters such as inline=true or inline=false are used to control whether a file is displayed directly in the browser (inline) or whether the browser triggers a file download.
/// inline=true: The file would be displayed directly in the browser if the file format is viewable (e.g., text, images).
/// inline=false: The file would prompt the browser to download it rather than display it in the browser window.

process downlodSAM {
storeDir params.temp
input:
val inurl
output:
path "SAMfile.sam"

"""
wget ${inurl} -O "SAMfile.sam"
""" 
}

process cleanSAM {
  publishDir params.out, mode: "copy", overwrite: true
  input:
    path infile 
  output:
    path "cleaned_sequences.sam"
  """
  cat $infile | grep -v "^@" > cleaned_sequences.sam
  """
}

process splitSAM {
  publishDir params.out, mode: "copy", overwrite: true
  input:
    path infile 
  output:
    path "sequence_*.fasta"
  """
  split -d -l 1 --additional-suffix .fasta $infile sequence_
  """
}

process samtoFASTA {
  publishDir params.out, mode: "copy", overwrite: true
  input:
    path infile 
  output:
    path "${infile.getSimpleName()}_correct.fasta"
  """
  echo -n ">" > ${infile.getSimpleName()}_correct.fasta
  cat $infile | cut -f 1 >> ${infile.getSimpleName()}_correct.fasta
  cat $infile | cut -f 10 >> ${infile.getSimpleName()}_correct.fasta
  """
}

process countStart {
  publishDir params.out, mode: "copy", overwrite: true
  input:
    path infile 
  output:
    path "${infile.getSimpleName()}_S_count.txt"
  """
  echo -n "Number of Start Codons: " > ${infile.getSimpleName()}_S_count.txt
  grep -o "ATG" $infile | wc -l >> ${infile.getSimpleName()}_S_count.txt
  """
}

workflow{
fastafile = downlodSAM(Channel.from(params.url)) | cleanSAM | splitSAM | flatten | samtoFASTA | countStart
}