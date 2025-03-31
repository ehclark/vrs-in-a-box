version 1.0

workflow VrsVcfAnnotator {
    input {
        File vcf_file
    }

    call VrsVcfAnnotatorTask {
        input:
            vcf_file = vcf_file
    }

    output {
        File output_vcf_file = VrsVcfAnnotatorTask.output_vcf_file
        File output_vrs_objects = VrsVcfAnnotatorTask.output_vrs_objects
    }

}

task VrsVcfAnnotatorTask {
    input {
        File vcf_file
    }

    command <<<
        vrs-annotate vcf --assembly GRCh38 "~{vcf_file}" --vcf-out "with_vrs_ids.vcf" --ndjson-out "vrs_objects.json"
    >>>

    runtime {
        docker: "vrs-vcf-annotator-grch38:latest"
        memory: "4GB"
    }

    output {
        File output_vcf_file = "with_vrs_ids.vcf"
        File output_vrs_objects = "vrs_objects.json"
    }
}
