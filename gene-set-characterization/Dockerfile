FROM knowengdev/geneset_characterization_pipeline:04_07_2017

WORKDIR /home/data/networks
RUN ls -al && gunzip -f STRING_experimental_gene_gene.edge.gz && \
    gunzip -f TEST_1_gene_gene.edge.gz && \
    gunzip -f TEST_1_property_gene.edge.gz && \
    gunzip -f kegg_pathway_property_gene.edge.gz

WORKDIR /home/data/spreadsheets
RUN ls -al && gunzip -f ProGENI_rwr20_STExp_GDSC_500.rname.gxc.tsv.gz && \
    gunzip -f ProGENI_rwr20_STExp_GDSC_500_MAP.rname.gxc.tsv.gz && \
    gunzip -f TEST_1_spreadsheet.tsv.gz && \
    gunzip -f TEST_1_spreadsheet_MAP.tsv.gz

WORKDIR /home/test
COPY parameters.yml entrypoint.sh ./

CMD [ "./entrypoint.sh" ]
