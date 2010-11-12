# http://gauravj.com/blog/2009/06/setting-asdoc-description-for-packages/
echo "Run from the main directory of juicekit-flex-visualizations to generate asdocs"
echo ""
echo "Output will be generated in target/asdoc-output/"
asdoc -doc-sources+=src/main/flex -external-library-path+=../juicekit-flex-core/bin/juicekit-flex-core.swc -external-library-path+=../juicekit-flex-data/bin/juicekit-flex-data.swc -package-description-file scripts/package-description-visualizations.xml -main-title "JuiceKit Visualizations API Documentation" -output -templates-path ../juicekit-flex-core/scripts/templates target/asdoc-output/
open target/asdoc-output/index.html
