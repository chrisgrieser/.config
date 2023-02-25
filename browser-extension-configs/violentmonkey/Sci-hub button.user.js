// ==UserScript==
// @name         Sci-hub button
// @namespace    https://greasyfork.org/zh-CN/scripts/370246-sci-hub-button
// @version      0.52
// @description  Add sci-hub button on article page. Add sci-hub button after article link. Support Google scholar, bing academic and baidu xueshu. Jump CNKI English article to Chinese article.
// @author       Dingar

// @match        *://AJHPContents.com/*
// @match        *://aaas.org/*
// @match        *://aacrmeetingabstracts.org/*
// @match        *://aaiddjournals.org/*
// @match        *://aanda.org/*
// @match        *://aapgbulletin.datapages.com/*
// @match        *://aas.aanda.org/*
// @match        *://academic.mintel.com/*
// @match        *://accessible.com/*
// @match        *://acm.org/*
// @match        *://adisonline.com/*
// @match        *://adsabs.harvard.edu/*
// @match        *://adswww.harvard.edu/*
// @match        *://advan.physiology.org/*
// @match        *://aeaweb.org/*
// @match        *://agronomy-journal.org/*
// @match        *://agu.org/*
// @match        *://ahiv.alexanderstreet.com/*
// @match        *://aiaa.org/*
// @match        *://aimsciences.org/*
// @match        *://aip.org/*
// @match        *://ajcn.org/*
// @match        *://ajcp.ascpjournals.org/*
// @match        *://ajevonline.org/*
// @match        *://ajh.sagepub.com/*
// @match        *://ajp.psychiatryonline.org/*
// @match        *://ajpcell.physiology.org/*
// @match        *://ajpendo.physiology.org/*
// @match        *://ajpgi.physiology.org/*
// @match        *://ajph.aphapublications.org/*
// @match        *://ajpheart.physiology.org/*
// @match        *://ajplegacy.physiology.org/*
// @match        *://ajplung.physiology.org/*
// @match        *://ajpregu.physiology.org/*
// @match        *://ajprenal.physiology.org/*
// @match        *://ajrccm.atsjournals.org/*
// @match        *://ajrcmb.org/*
// @match        *://ajslp.asha.org/*
// @match        *://ajsonline.org/*
// @match        *://ajtmh.org/*
// @match        *://ala.org/*
// @match        *://als.dukejournals.org/*
// @match        *://americana.ncsu.edu/*
// @match        *://americanliterature.dukejournals.org/*
// @match        *://americanspeech.dukejournals.org/*
// @match        *://amjbot.org/*
// @match        *://ams.org/*
// @match        *://amsciepub.com/*
// @match        *://analusis.edpsciences.org/*
// @match        *://anb.org/*
// @match        *://andrologyjournal.org/*
// @match        *://animres.edpsciences.org/*
// @match        *://annals.org/*
// @match        *://annee-philologique.com/*
// @match        *://annphys.org/*
// @match        *://annualreviews.org/*
// @match        *://anthrosource.net/*
// @match        *://apex.ipap.jp/*
// @match        *://apidologie.org/*
// @match        *://app.harpweek.com/*
// @match        *://appliedradiology.com/*
// @match        *://apps.isiknowledge.com/*
// @match        *://aps.org/*
// @match        *://apsjournals.apsnet.org/*
// @match        *://archderm.ama-assn.org/*
// @match        *://archinte.ama-assn.org/*
// @match        *://archive.pepublishing.com/*
// @match        *://archives.chadwyck.com/*
// @match        *://archneur.ama-assn.org/*
// @match        *://archopht.ama-assn.org/*
// @match        *://archpsyc.ama-assn.org/*
// @match        *://archsurg.ama-assn.org/*
// @match        *://arjournals.annualreviews.org/*
// @match        *://artstor.org/*
// @match        *://asadl.org/*
// @match        *://asae.frymulti.com/*
// @match        *://ascelibrary.org/*
// @match        *://asianannals.ctsnetjournals.org/*
// @match        *://aslo.org/*
// @match        *://aspet.org/*
// @match        *://aspresolver.com/*
// @match        *://atypon-link.com/*
// @match        *://aviationweek.com/*
// @match        *://avmajournals.avma.org/*
// @match        *://bas.umdl.umich.edu/*
// @match        *://bbmt.org/*
// @match        *://bepress.com/*
// @match        *://berrymaninstitute.org/*
// @match        *://biochemj.org/*
// @match        *://biochemsoctrans.org/*
// @match        *://biol.uni.wroc.pl/*
// @match        *://biolbull.org/*
// @match        *://biolreprod.org/*
// @match        *://bioone.org/*
// @match        *://bioscirep.org/*
// @match        *://biotechniques.com/*
// @match        *://blackwell-synergy.com/*
// @match        *://bloodjournal.hematologylibrary.org/*
// @match        *://bmj.com/*
// @match        *://bna.birds.cornell.edu/*
// @match        *://bos.frb.org/*
// @match        *://botany.org/*
// @match        *://boundary2.dukejournals.org/*
// @match        *://britannica.com/*
// @match        *://bsas.org.uk/*
// @match        *://bssaonline.org/*
// @match        *://bul.sagepub.com/*
// @match        *://businessweek.com/*
// @match        *://cabdirect.org/*
// @match        *://cabi.org/*
// @match        *://cameraobscura.dukejournals.org/*
// @match        *://cancerres.aacrjournals.org/*
// @match        *://canreviews.aacrjournals.org/*
// @match        *://carbo.chemnetbase.com/*
// @match        *://cawq.ca/*
// @match        *://ccd.chemnetbase.com/*
// @match        *://ccl.sagepub.com/*
// @match        *://cell.com/*
// @match        *://cgd.aacrjournals.org/*
// @match        *://checkpoint.riag.com/*
// @match        *://chelonianjournals.org/*
// @match        *://chemnetbase.com/*
// @match        *://chestjournal.chestpubs.org/*
// @match        *://chicagomanualofstyle.org/*
// @match        *://china.eastview.com/*
// @match        *://choicesmagazine.org/*
// @match        *://chronicle.com/*
// @match        *://ci.nii.ac.jp/*
// @match        *://ciaonet.org/*
// @match        *://cindasdata.com/*
// @match        *://ciw.edu/*
// @match        *://cjc-online.ca/*
// @match        *://cl.uwpress.org/*
// @match        *://clevelandfed.org/*
// @match        *://clincancerres.aacrjournals.org/*
// @match        *://clinchem.org/*
// @match        *://clinmed.netprints.org/*
// @match        *://clinsci.org/*
// @match        *://cms.math.ca/*
// @match        *://cnki.en.eastview.com/*
// @match        *://collections.chadwyck.com/*
// @match        *://communicationencyclopedia.com/*
// @match        *://complit.dukejournals.org/*
// @match        *://computerworld.com/*
// @match        *://consumerinterests.org/*
// @match        *://contemporaryobgyn.net/*
// @match        *://content.karger.com/*
// @match        *://corporateaffiliations.com/*
// @match        *://crcnetbase.com/*
// @match        *://crl.acrl.org/*
// @match        *://crln.acrl.org/*
// @match        *://cro2.org/*
// @match        *://cshmonographs.org/*
// @match        *://cshprotocols.cshlp.org/*
// @match        *://csi.sagepub.com/*
// @match        *://dandini.emeraldinsight.com/*
// @match        *://darwin.edu.ar/*
// @match        *://db.chemsources.com/*
// @match        *://dccc.chemnetbase.com/*
// @match        *://dev.biologists.org/*
// @match        *://dfc.chemnetbase.com/*
// @match        *://dichtung-digital.de/*
// @match        *://digital.library.mcgill.ca/*
// @match        *://digitalmicrofilm.proquest.com/*
// @match        *://dioc.chemnetbase.com/*
// @match        *://discovermagazine.com/*
// @match        *://dl.acm.org/*
// @match        *://dl.begellhouse.com/*
// @match        *://dlib.eastview.com/*
// @match        *://dmd.aspetjournals.org/*
// @match        *://dmnp.chemnetbase.com/*
// @match        *://dx.doi.org/*
// @match        *://ebm.rsmjournals.com/*
// @match        *://ebook.rsc.org/*
// @match        *://economist.com/*
// @match        *://edgj.org/*
// @match        *://edm.sagepub.com/*
// @match        *://edpsciences.org/*
// @match        *://edrv.endojournals.org/*
// @match        *://educationbook.aacrjournals.org/*
// @match        *://eebo.chadwyck.com/*
// @match        *://eenews.net/*
// @match        *://ehq.sagepub.com/*
// @match        *://ejorel.com/*
// @match        *://electrochem.org/*
// @match        *://elementsmagazine.org/*
// @match        *://els.net/*
// @match        *://ema.sagepub.com/*
// @match        *://emeraldinsight.com/*
// @match        *://ems-ph.org/*
// @match        *://endo.endojournals.org/*
// @match        *://engineeringvillage2.com/*
// @match        *://enterprise.astm.org/*
// @match        *://epirev.oupjournals.org/*
// @match        *://epjap.org/*
// @match        *://epubs.ans.org/*
// @match        *://er.uwpress.org/*
// @match        *://erc.endocrinology-journals.org/*
// @match        *://erg.sagepub.com/*
// @match        *://esa.publisher.ingentaconnect.com/*
// @match        *://esajournals.org/*
// @match        *://etde.org/*
// @match        *://ethnohistory.dukejournals.org/*
// @match        *://europhysicsnews.org/*
// @match        *://evolutionary-ecology.com/*
// @match        *://exacteditions.com/*
// @match        *://extensionreport.osu.edu/*
// @match        *://facs.org/*
// @match        *://familiesinsociety.org/*
// @match        *://fao.org/*
// @match        *://fasebj.org/*
// @match        *://fhs.dukejournals.org/*
// @match        *://fiaf.chadwyck.com/*
// @match        *://find.acacamps.org/*
// @match        *://find.galegroup.com/*
// @match        *://firstsearch.oclc.org/*
// @match        *://fundingopps2.cos.com/*
// @match        *://fyesit.metapress.com/*
// @match        *://gateway.proquest.com/*
// @match        *://genesdev.cshlp.org/*
// @match        *://genetics.org/*
// @match        *://genome.cshlp.org/*
// @match        *://genomebiology.com/*
// @match        *://geology.gsapubs.org/*
// @match        *://giorgio.ingentaselect.com/*
// @match        *://global-sci.com/*
// @match        *://glq.dukejournals.org/*
// @match        *://gmr.minsocam.org/*
// @match        *://gpoaccess.gov/*
// @match        *://groveart.com/*
// @match        *://grovemusic.com/*
// @match        *://gsabulletin.gsapubs.org/*
// @match        *://gse-journal.org/*
// @match        *://gut.bmj.com/*
// @match        *://hahr.dukejournals.org/*
// @match        *://hapi.gseis.ucla.edu/*
// @match        *://heart.bmj.com/*
// @match        *://heinonline.org/*
// @match        *://hh.um.es/*
// @match        *://hope.dukejournals.org/*
// @match        *://hortsci.ashspublications.org/*
// @match        *://horttech.ashspublications.org/*
// @match        *://hsus.cambridge.org/*
// @match        *://hti.umich.edu/*
// @match        *://hull.ac.uk/*
// @match        *://ias.ac.in/*
// @match        *://ibe.sagepub.com/*
// @match        *://ibisworld.com/*
// @match        *://ibra.org.uk/*
// @match        *://icevirtuallibrary.com/*
// @match        *://icf.uab.es/*
// @match        *://ici.org/*
// @match        *://ida.liu.se/*
// @match        *://ieee.org/*
// @match        *://ieeexplore.ieee.org/*
// @match        *://ihserc.com/*
// @match        *://iimp.chadwyck.com/*
// @match        *://ijc.org/*
// @match        *://ijdb.ehu.es/*
// @match        *://ijee.ie/*
// @match        *://ijs.sgmjournals.org/*
// @match        *://impublications.com/*
// @match        *://inda.org/*
// @match        *://informahealthcare.com/*
// @match        *://informaworld.com/*
// @match        *://infotrac.galegroup.com/*
// @match        *://infoweb.newsbank.com/*
// @match        *://ingentaconnect.com/*
// @match        *://ingentaselect.com/*
// @match        *://inpractice.bmj.com/*
// @match        *://inscribe.iupress.org/*
// @match        *://int-res.com/*
// @match        *://interfaces.journal.informs.org/*
// @match        *://interscience.wiley.com/*
// @match        *://iop.org/*
// @match        *://iopscience.iop.org/*
// @match        *://iovs.org/*
// @match        *://ipap.jp/*
// @match        *://ir.uiowa.edu/*
// @match        *://isiknowledge.com/*
// @match        *://isr.journal.informs.org/*
// @match        *://itergateway.org/*
// @match        *://itn.is/*
// @match        *://iucn.org/*
// @match        *://iupac.org/*
// @match        *://iwaponline.com/*
// @match        *://jaaha.org/*
// @match        *://jama.ama-assn.org/*
// @match        *://jap.physiology.org/*
// @match        *://japr.fass.org/*
// @match        *://jas.fass.org/*
// @match        *://jbc.org/*
// @match        *://jbjs.org/*
// @match        *://jbmronline.org/*
// @match        *://jcb.rupress.org/*
// @match        *://jcem.endojournals.org/*
// @match        *://jco.ascopubs.org/*
// @match        *://jcp.bmj.com/*
// @match        *://jcs.biologists.org/*
// @match        *://jeb.biologists.org/*
// @match        *://jem.rupress.org/*
// @match        *://jgp.rupress.org/*
// @match        *://jgs.lyellcollection.org/*
// @match        *://jgslegacy.lyellcollection.org/*
// @match        *://jhortscib.org/*
// @match        *://jhr.uwpress.org/*
// @match        *://jhse.org/*
// @match        *://jimmunol.org/*
// @match        *://jleukbio.org/*
// @match        *://jlr.org/*
// @match        *://jme.endocrinology-journals.org/*
// @match        *://jmems.dukejournals.org/*
// @match        *://jmm.sgmjournals.org/*
// @match        *://jn.nutrition.org/*
// @match        *://jn.physiology.org/*
// @match        *://jneurosci.org/*
// @match        *://jnm.snmjournals.org/*
// @match        *://jnnp.bmj.com/*
// @match        *://jnrlse.org/*
// @match        *://joa.isa-arbor.com/*
// @match        *://joc.journal.informs.org/*
// @match        *://joe.endocrinology-journals.org/*
// @match        *://john-libbey-eurotext.fr/*
// @match        *://journal.ashspublications.org/*
// @match        *://journal.telospress.com/*
// @match        *://journals.ametsoc.org/*
// @match        *://journals.cambridge.org/*
// @match        *://journals.hil.unb.ca/*
// @match        *://journals.humankinetics.com/*
// @match        *://journals.iucr.org/*
// @match        *://journals.naspa.org/*
// @match        *://journals.sagamorepub.com/*
// @match        *://journals.tdl.org/*
// @match        *://journalstp.gracescientific.com/*
// @match        *://jove.com/*
// @match        *://jp.physoc.org/*
// @match        *://jpet.aspetjournals.org/*
// @match        *://jpsj.ipap.jp/*
// @match        *://jsad.com/*
// @match        *://jsedres.sepmonline.org/*
// @match        *://jslhr.asha.org/*
// @match        *://jstage.jst.go.jp/*
// @match        *://jstor.org/*
// @match        *://jswconline.org/*
// @match        *://jwildlifedis.org/*
// @match        *://jyi.org/*
// @match        *://kluwerlawonline.com/*
// @match        *://kluweronline.com/*
// @match        *://knovel.com/*
// @match        *://la.rsmjournals.com/*
// @match        *://labanimal.com/*
// @match        *://labor.dukejournals.org/*
// @match        *://landesbioscience.com/*
// @match        *://le.uwpress.org/*
// @match        *://lexis-nexis.com/*
// @match        *://lexisnexis.com/*
// @match        *://library.cqpress.com/*
// @match        *://library.pressdisplay.com/*
// @match        *://library.seg.org/*
// @match        *://libraryissues.com/*
// @match        *://liebertonline.com/*
// @match        *://link.springer-ny.com/*
// @match        *://link.springer.de/*
// @match        *://links.jstor.org/*
// @match        *://livingbird.org/*
// @match        *://lj.uwpress.org/*
// @match        *://mansci.journal.informs.org/*
// @match        *://mapress.com/*
// @match        *://math.ualberta.ca/*
// @match        *://mcponline.org/*
// @match        *://mcr.aacrjournals.org/*
// @match        *://mcr.sagepub.com/*
// @match        *://mend.endojournals.org/*
// @match        *://metapress.com/*
// @match        *://metla.fi/*
// @match        *://mic.sgmjournals.org/*
// @match        *://millerpublishing.com/*
// @match        *://minsocam.org/*
// @match        *://mitpressjournals.org/*
// @match        *://mktsci.journal.informs.org/*
// @match        *://mlajournals.org/*
// @match        *://mluri.sari.ac.uk/*
// @match        *://mmm.edpsciences.org/*
// @match        *://molbiolcell.org/*
// @match        *://molpharm.aspetjournals.org/*
// @match        *://mor.journal.informs.org/*
// @match        *://mp.bmj.com/*
// @match        *://mq.dukejournals.org/*
// @match        *://msp.berkeley.edu/*
// @match        *://msucares.com/*
// @match        *://muse.jhu.edu/*
// @match        *://museumoftheearth.org/*
// @match        *://mycologia.org/*
// @match        *://myinsight.ihsglobalinsight.com/*
// @match        *://nactateachers.org/*
// @match        *://nationaljournal.com/*
// @match        *://nature.com/*
// @match        *://nber.org/*
// @match        *://nc-apa.org/*
// @match        *://ncbi.nlm.nih.gov/*
// @match        *://ncbiotech.org/*
// @match        *://nccsdataweb.urban.org/*
// @match        *://ncdjjdp.org/*
// @match        *://ncjrs.org/*
// @match        *://nclive.org/*
// @match        *://ncph.org/*
// @match        *://ncpublicschools.org/*
// @match        *://ncsu.naxosmusiclibrary.com/*
// @match        *://ncte.org/*
// @match        *://nejm.org/*
// @match        *://netLibrary.com/*
// @match        *://netadvantage.standardandpoors.com/*
// @match        *://netlibrary.com/*
// @match        *://new.sourceoecd.org/*
// @match        *://news.reseau-concept.net/*
// @match        *://ngc.dukejournals.org/*
// @match        *://nho.sagepub.com/*
// @match        *://nonlin-processes-geophys.net/*
// @match        *://novel.dukejournals.org/*
// @match        *://npprj.spci.se/*
// @match        *://nrcresearchpress.com/*
// @match        *://nsarchive.chadwyck.com/*
// @match        *://nsrl.ttu.edu/*
// @match        *://nucl.annualreviews.org/*
// @match        *://nv-med.com/*
// @match        *://nybooks.com/*
// @match        *://observateurocde.org/*
// @match        *://oecd-ilibrary.org/*
// @match        *://oecdobserver.org/*
// @match        *://oed.com/*
// @match        *://oldcitypublishing.com/*
// @match        *://online.sagepub.com/*
// @match        *://onlinelibrary.wiley.com/*
// @match        *://ophthalmologytimes.modernmedicine.com/*
// @match        *://opticsinfobase.org/*
// @match        *://or.journal.informs.org/*
// @match        *://orgsci.journal.informs.org/*
// @match        *://osa-opn.org/*
// @match        *://ovidsp.ovid.com/*
// @match        *://oxfordlanguagedictionaries.com/*
// @match        *://oxfordmusiconline.com/*
// @match        *://pacificarchaeology.org/*
// @match        *://pads.dukejournals.org/*
// @match        *://palgrave-journals.com/*
// @match        *://papers.nber.org/*
// @match        *://pasj.asj.or.jp/*
// @match        *://peanutscience.com/*
// @match        *://pedagogy.dukejournals.org/*
// @match        *://perceptionweb.com/*
// @match        *://pgrsa.org/*
// @match        *://pharmacists.ca/*
// @match        *://pharmrev.aspetjournals.org/*
// @match        *://philreview.dukejournals.org/*
// @match        *://phycologia.org/*
// @match        *://physicsweb.org/*
// @match        *://physicsworldarchive.iop.org/*
// @match        *://physiolgenomics.physiology.org/*
// @match        *://physrev.physiology.org/*
// @match        *://plantcell.org/*
// @match        *://plantmanagementnetwork.org/*
// @match        *://plantphysiol.org/*
// @match        *://pld.chadwyck.com/*
// @match        *://podiatrytoday.com/*
// @match        *://poeticstoday.dukejournals.org/*
// @match        *://polymersdatabase.com/*
// @match        *://portal.acm.org/*
// @match        *://portal.euromonitor.com/*
// @match        *://portico.org/*
// @match        *://positions.dukejournals.org/*
// @match        *://pracademics.com/*
// @match        *://priory.com/*
// @match        *://prisma.chadwyck.com/*
// @match        *://products.asminternational.org/*
// @match        *://projecteuclid.org/*
// @match        *://proquest.safaribooksonline.com/*
// @match        *://proquest.umi.com/*
// @match        *://proxying.lib.ncsu.edu/*
// @match        *://ps.fass.org/*
// @match        *://ptp.ipap.jp/*
// @match        *://publicculture.dukejournals.org/*
// @match        *://publish.csiro.au/*
// @match        *://pubs.acs.org/*
// @match        *://pubs.aic.ca/*
// @match        *://pubs.amstat.org/*
// @match        *://pubservices.nrc-cnrc.ca/*
// @match        *://purl.access.gpo.gov/*
// @match        *://pwq.sagepub.com/*
// @match        *://qjps.com/*
// @match        *://quod.lib.umich.edu/*
// @match        *://radiology.rsna.org/*
// @match        *://railwayage.com/*
// @match        *://raj.sagepub.com/*
// @match        *://reading.org/*
// @match        *://redbooks.com/*
// @match        *://reference-global.com/*
// @match        *://referenceusa.com/*
// @match        *://refuniv.odyssi.com/*
// @match        *://reproduction-online.org/*
// @match        *://revista-iberoamericana.pitt.edu/*
// @match        *://revophth.com/*
// @match        *://rff.org/*
// @match        *://rhr.dukejournals.org/*
// @match        *://rnajournal.cshlp.org/*
// @match        *://rnd.edpsciences.org/*
// @match        *://ropercenter.uconn.edu/*
// @match        *://rothamsted.bbsrc.ac.uk/*
// @match        *://royalsociety.org.nz/*
// @match        *://rphr.endojournals.org/*
// @match        *://rsc.org/*
// @match        *://rsh.sagepub.com/*
// @match        *://sagamorepub.com/*
// @match        *://sanborn.umi.com/*
// @match        *://saq.dukejournals.org/*
// @match        *://sbrnet.com/*
// @match        *://schattauer.de/*
// @match        *://scholar.google.com/*
// @match        *://sciencedirect.com/*
// @match        *://sciencemag.org/*
// @match        *://scientific.net/*
// @match        *://seab.envmed.rochester.edu/*
// @match        *://search.ebscohost.com/*
// @match        *://search.epnet.com/*
// @match        *://search.marquiswhoswho.com/*
// @match        *://search.proquest.com/*
// @match        *://search.rdsinc.com/*
// @match        *://searchcenter.intelecomonline.net/*
// @match        *://seg.org/*
// @match        *://services.bepress.com/*
// @match        *://simplymap.com/*
// @match        *://site.ebrary.com/*
// @match        *://slac.stanford.edu/*
// @match        *://social.chass.ncsu.edu/*
// @match        *://socialtext.dukejournals.org/*
// @match        *://societyforchaostheory.org/*
// @match        *://spie.org/*
// @match        *://spiedl.org/*
// @match        *://springerlink.com/*
// @match        *://springerlink.de/*
// @match        *://springerlink.metapress.com/*
// @match        *://springerprotocols.com/*
// @match        *://ssh.dukejournals.org/*
// @match        *://stacks.iop.org/*
// @match        *://statpak.gov.pk/*
// @match        *://stepsheet.stsci.edu/*
// @match        *://stke.sciencemag.org/*
// @match        *://swissmedic.ch/*
// @match        *://symposium.cshlp.org/*
// @match        *://tandfonline.com/*
// @match        *://tannerlectures.utah.edu/*
// @match        *://tappi.micronexx.com/*
// @match        *://taw.sagepub.com/*
// @match        *://technologyreview.com/*
// @match        *://theannals.com/*
// @match        *://theater.dukejournals.org/*
// @match        *://thecochranelibrary.com/*
// @match        *://theiwrc.org/*
// @match        *://thejns.org/*
// @match        *://themerckindex.cambridgesoft.com/*
// @match        *://theses.com/*
// @match        *://thomist.org/*
// @match        *://toxnet.nlm.nih.gov/*
// @match        *://transci.journal.informs.org/*
// @match        *://trb.org/*
// @match        *://turf.lib.msu.edu/*
// @match        *://turpion.org/*
// @match        *://tvnews.vanderbilt.edu/*
// @match        *://uark.edu/*
// @match        *://uli.org/*
// @match        *://ulrichsweb.com/*
// @match        *://unstats.un.org/*
// @match        *://vdi.sagepub.com/*
// @match        *://veterinaryrecord.bmj.com/*
// @match        *://vetres.org/*
// @match        *://vha.usc.edu/*
// @match        *://victoriandatabase.com/*
// @match        *://victorianperiodicals.com/*
// @match        *://vir.sgmjournals.org/*
// @match        *://vnweb.hwwilsonweb.com/*
// @match        *://web.jbjs.org.uk/*
// @match        *://web.lexis-nexis.com/*
// @match        *://wgsn.com/*
// @match        *://whiv.alexanderstreet.com/*
// @match        *://wilsonweb2.hwwilson.com/*
// @match        *://wkap.nl/*
// @match        *://worldscinet.com/*
// @match        *://worldscinetarchives.com/*
// @match        *://worldshakesbib.org/*
// @match        *://wrds-web.wharton.upenn.edu/*
// @match        *://wssa.allenpress.com/*
// @match        *://wto.org/*
// @match        *://www-pub.iaea.org/*
// @match        *://www2.acs.ncsu.edu/*
// @match        *://www3.interscience.wiley.com/*
// @match        *://www3.nationaljournal.com/*
// @match        *://www3.stat.sinica.edu.tw/*
// @match        *://xlink.rsc.org/*
// @match        *://ybook.co.jp/*
// @match        *://zentralblatt-math.org/*
// @match        *://znaturforsch.com/*
// @match        http://*.aasv.org/*
// @match        http://*.acm.org/*
// @match        http://*.acs.org/*
// @match        http://*.baidu.com/*
// @match        http://*.biomedcentral.com/*
// @match        http://*.bioon.com.cn/*
// @match        http://*.bmj.com/*
// @match        http://*.cabdirect.org/*
// @match        http://*.cambridge.org/*
// @match        http://*.cell.com/*
// @match        http://*.cnki.com.cn/*
// @match        http://*.cnki.net/*
// @match        http://*.cqvip.com/*
// @match        http://*.csiro.au/*
// @match        http://*.csis.cn/*
// @match        http://*.edu.cn/*
// @match        http://*.edu/*
// @match        http://*.en.cnki.com.cn/*
// @match        http://*.europepmc.org/*
// @match        http://*.frontiersin.org/*
// @match        http://*.google.com.co.uk/*
// @match        http://*.google.com.hk/*
// @match        http://*.google.com/*
// @match        http://*.google.nl/*
// @match        http://*.j-csam.org/*
// @match        http://*.jstor.org/*
// @match        http://*.mr-gut.cn/*
// @match        http://*.nature.com/*
// @match        http://*.ncbi.nlm.nih.gov/*
// @match        http://*.oxfordjournals.org/*
// @match        http://*.physiology.org/*
// @match        http://*.plos.org/*
// @match        http://*.plosjournals.org/*
// @match        http://*.plosone.org/*
// @match        http://*.pnas.org/*
// @match        http://*.pubmed.cn/*
// @match        http://*.pubmed.com/*
// @match        http://*.pubmedcentral.nih.gov/*
// @match        http://*.pubmedcentralcanada.ca/*
// @match        http://*.researchgate.net/*
// @match        http://*.sci-hub.is/*
// @match        http://*.sci-hub.mu/*
// @match        http://*.sci-hub.se/*
// @match        http://*.sci-hub.tw/*
// @match        http://*.sciencedirect.com/*
// @match        http://*.sciencemag.org/*
// @match        http://*.springer.com/*
// @match        http://*.springerlink.com/*
// @match        http://*.tandfonline.com/*
// @match        http://*.tcsae.org/*
// @match        http://*.thelancet.com/*
// @match        http://*.wanfangdata.com.cn/*
// @match        http://*.wiley.com/*
// @match        http://*.worldscientific.com/*
// @match        http://*/doi/abs/*
// @match        http://*/doi/full/*
// @match        http://cqvip.com/*
// @match        http://doi.org/*
// @match        http://dx.doi.org/*
// @match        http://europepmc.org/*
// @match        http://inspirehep.net/
// @match        http://inspirehep.net/*
// @match        http://pubmed.cn/*
// @match        http://pubmed.com/*
// @match        http://pubmedcentralcanada.ca/*
// @match        http://researcherslinks.com/*
// @match        http://sci-hub.is/*
// @match        http://sci-hub.mu/*
// @match        http://sci-hub.se/*
// @match        http://sci-hub.tw/*
// @match        https://*.aasv.org/*
// @match        https://*.acs.org/*
// @match        https://*.aip.org/*
// @match        https://*.aps.org/*
// @match        https://*.arch-anim-breed.net/*
// @match        https://*.asm.org/*
// @match        https://*.bing.com/*
// @match        https://*.biomedcentral.com/*
// @match        https://*.bioon.com/*
// @match        https://*.bmj.com/
// @match        https://*.bmj.com/*
// @match        https://*.cambridge.org/*
// @match        https://*.cell.com/*
// @match        https://*.cn-ki.net/*
// @match        https://*.edu/*
// @match        https://*.frontiersin.org/*
// @match        https://*.futuremedicine.com/*
// @match        https://*.google.com.co.uk/*
// @match        https://*.google.com.hk/*
// @match        https://*.google.com/*
// @match        https://*.google.nl/*
// @match        https://*.ieee.org/*
// @match        https://*.journalofinfection.com/*
// @match        https://*.jstor.org/*
// @match        https://*.livestockscience.com/*
// @match        https://*.mr-gut.cn/*
// @match        https://*.nature.com/*
// @match        https://*.ncbi.nlm.nih.gov/*
// @match        https://*.oup.com/*
// @match        https://*.oxfordjournals.org/*
// @match        https://*.physiology.org/*
// @match        https://*.plos.org/*
// @match        https://*.plosjournals.org/*
// @match        https://*.plosone.org/*
// @match        https://*.royalsocietypublishing.org/*
// @match        https://*.sci-hub.mu/*
// @match        https://*.sci-hub.tw/*
// @match        https://*.sci-hub.win/*
// @match        https://*.sciencedirect.com/*
// @match        https://*.springer.com/*
// @match        https://*.tandfonline.com/*
// @match        https://*.unesp.br/*
// @match        https://*.webofknowledge.com/*
// @match        https://*.wikipedia.org/
// @match        https://*.wikipedia.org/*
// @match        https://*.wiley.com/*
// @match        https://*/doi/abs/*
// @match        https://*/doi/full/*
// @match        https://aip.scitation.org/
// @match        https://aip.scitation.org/*
// @match        https://arxiv.org/
// @match        https://arxiv.org/*
// @match        https://doi.org/*
// @match        https://en.wikipedia.org/
// @match        https://en.wikipedia.org/*
// @match        https://europepmc.org/*
// @match        https://ieeexplore.ieee.org/
// @match        https://ieeexplore.ieee.org/*
// @match        https://iopscience.iop.org/
// @match        https://iopscience.iop.org/*
// @match        https://journals.aps.org/
// @match        https://journals.aps.org/*
// @match        https://mp.weixin.qq.com/s*
// @match        https://paperpile.com/app
// @match        https://peerj.com/*
// @match        https://pnas.org/*
// @match        https://pubs.acs.org.ccindex.cn/*
// @match        https://pubs.rsc.org/*
// @match        https://sci-hub.mu/*
// @match        https://sci-hub.tw/*
// @match        https://sci-hub.win/*
// @match        https://science.sciencemag.org/
// @match        https://science.sciencemag.org/*
// @match        https://ui.adsabs.harvard.edu/
// @match        https://ui.adsabs.harvard.edu/*
// @match        https://www.ajas.info/*
// @match        https://www.biorxiv.org/*
// @match        https://www.ejog.org/*
// @match        https://www.ingentaconnect.com/*
// @match        https://www.koreascience.or.kr/article/*.page
// @match        https://www.mdpi.com/*
// @match        https://www.nrcresearchpress.com/
// @match        https://www.osapublishing.org/
// @match        https://www.osapublishing.org/*
// @match        https://www.prophy.science/
// @match        https://www.prophy.science/*
// @match        https://www.researchgate.net/
// @match        https://www.researchgate.net/*
// @match        https://www.scitation.org/
// @match        https://www.scitation.org/*
// @match        https://www.semanticscholar.org/
// @match        https://www.semanticscholar.org/*
// @match        https://www.worldscientific.com/
// @match        https://www.x-mol.com/paper/*
// @match        https://xueshu.baidu.com/*
// @match        https://zhuanlan.zhihu.com/p/*


// @icon         data:image/x-icon;base64,AAABAAcAMDAAAAEACACoDgAAdgAAACAgAAABAAgAqAgAAB4PAAAQEAAAAQAIAGgFAADGFwAAAAAAAAEAIABkegAALh0AADAwAAABACAAqCUAAJKXAAAgIAAAAQAgAKgQAAA6vQAAEBAAAAEAIABoBAAA4s0AACgAAAAwAAAAYAAAAAEACAAAAAAAAAkAAAAAAAAAAAAAAAEAAAABAAAAAAAAACrIAAAuygAAMcoAAzTLAAQ1ywAAMswAATXMAAU2zAACOc0ABDnNAAU9zwAJOc0ADDvOABA+zgAFP9AAEkHPABVCzwAXRM8ABUHQAAZF0QAIRdEAB0nTAAhJ0wAIS9QACU3UABtH0QAKUNUADFPWAAxV1gAMVtgADVnYAA5d2QAQXtoAIk7SACZQ0gAtV9UAMFjUADRb1QAPYNoAEGHaABFl3AASad0AFGjdABNs3QAUbt8AFXDfAChm2gA9ZNgAFXHgABZ14QAXeeIAGHviABh94gAef+MAGX3kAEFn2QBJbdoATnDaAFBy2wBXeN0AXn3eABqB5QAcguQAHIXmAB2I5wAdiugAHo3pAB+Q6gAgkuoAIJTrACGW7AAhmewAI5ztACSf7gA0nusAMKbuACSh8AAmpfAAJ6nyACiq8gAorfIAKa70ACmx8wAqsvUAK7X2ACy39QAsufYALLr4AC69+AAxvPcAZILfAEuE4gBcg+AAaYbgAHmT4wB7lOQAL8H5ADDD+gAwxfoAMMb8ADHI+wAyyv0ANMv+ADLM/gA1zP4AOs3+AD3N/gA00P4AQc7+AEPQ/wBF0P8ASdD+AE3R/gBR0v4AVtT+AFrV/gBe1v4AYtf+AG/U+QBj2P8Aatn+AG/b/wBx2/4Ac9z/AHXc/gB53f4Aft7+AIPe/QCF4P4AiOD+AI3i/gCR4/4AluT+AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAD///8AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAIR+AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAB+a2lrAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAdGlpaWlphAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAgm5paWlpaWlpcQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAHpraWlpaWlpaWlpaQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAB0aWlpaWlpaWlpaWlpaXYAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACEbmlpaWlpaWlpaWlpaWlpaWsAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAemtpaWlpaWlpaWlpaWlpaWlpaWl+AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAHRpaWlpaWlpaWlpaWlpaWlpaWlpaWlrAAAAAAAAAAAAAAAAAAAAAAAAAAAAAH9taWlpaWlpaWlpaWlpaWlpaWlpaWlpaWlphAAA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AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAADPM/w4zzP9OM8z/rjLL/vAzzP/9M8z/9DLL/i4AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAyy/4ZMsv+bDLL/swyy/75Msv+/jLL/v4yy/7+Msv+/jLL/owyy/4BAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAzzP8FMsv+NzPM/5YzzP/qMsv+/jPM//8zzP//M8z//zLL/v4zzP//M8z//zLL/t4zzP8aAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAMsv+DTPM/1AzzP+zMsv+8TPM//4zzP//Msv+/jPM//8zzP//M8z//zLL/v4zzP//M8z//zLL/vszzP9oAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAADLL/hoyy/5wMsv+zDLL/vgyy/7+Msv+/jLL/v4yy/7+Msv+/jLL/v4yy/7+Msv+/jLL/v4yy/7+Msv+/jLL/v4yy/7DMsv+CgAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAADPM/wgzzP84Msv+lDPM/+gzzP/+Msv+/jPM//8zzP//Msv+/jPM//8zzP//Msv+/jPM//8zzP//M8z//zLL/v4zzP//M8z//zLL/v4zzP/1M8z/SAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAADPM/wEzzP8TMsv+VjPM/7kzzP/vMsv+/jPM//8zzP//Msv+/jPM//8zzP//Msv+/jPM//8zzP//Msv+/jPM//8zzP//M8z//zLL/v4zzP//M8z//zLL/v4zzP/+M8z/rTLL/gMAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAzzP8BMsv+HjPM/3szzP/QMsv++jPM//8zzP//Msv+/jPM//8zzP//Msv+/jPM//8zzP//Msv+/jPM//8zzP//Msv+/jPM//8zzP//M8z//zLL/v4zzP//M8z//zLL/v4zzP//M8z/9DLL/igAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAMsv+BTLL/j4yy/6gMsv+7TLL/v4yy/7+Msv+/jLL/v4yy/7+Msv+/jLL/v4yy/7+Msv+/jLL/v4yy/7+Msv+/jLL/v4yy/7+Msv+/jLL/v4yy/7+Msv+/jLL/v4yy/7+Msv+/jLL/v4yy/7+Msv+/jLL/ocyy/4CAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAADPM/xQzzP9ZM8z/uDLL/vIzzP/+Msv+/jPM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/v4yy/7yMsv+ujLL/lYyy/4OAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAMsv+ATPM/8IzzP//Msv+/jPM//8zzP//Msv+/jPM//8zzP//Msv+/jPM//8zzP//Msv+/jPM//8zzP//Msv+/jPM//8zzP//M8z//zLL/v4zzP/8M8z/5TLL/pczzP85M8z/CgAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAADPM/1szzP/7Msv+/jPM//8zzP//Msv+/jPM//8zzP//Msv+/jPM//8zzP//Msv+/jPM//8zzP//Msv+/jPM//8zzP//M8z/+zLL/tAzzP93M8z/JDLL/gIAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAADLL/hMyy/7YMsv+/jLL/v4yy/7+Msv+/jLL/v4yy/7+Msv+/jLL/v4yy/7+Msv+/jLL/v4yy/7+Msv+/jLL/u4yy/6tMsv+SzLL/goAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAzzP9/Msv+/jPM//8zzP//Msv+/jPM//8zzP//Msv+/jPM//8zzP//Msv+/jPM//wzzP/fMsv+jjPM/zAzzP8GAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAzzP8qMsv+7TPM//8zzP//Msv+/jPM//8zzP//Msv+/jPM//8zzP/9Msv+0TPM/2szzP8dMsv+AQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAyy/4EMsv+pjLL/v4yy/7+Msv+/jLL/v4yy/7+Msv+7zLL/qsyy/5LMsv+CQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAMsv+QzPM//0zzP//Msv+/DPM/90zzP+KMsv+MDPM/wUAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAMsv+BjPM/8wzzP/NMsv+azPM/xcAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAADLL/hcyy/4EAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAP///////wAA////////AAD///////8AAP////+H/wAA/////Af/AAD////wA/8AAP///4AD/wAA///+AAP/AAD///gAAf8AAP//wAAB/wAA//4AAAD/AAD/+AAAAP8AAP/gAAAAfwAA/4AAAAB/AAD+AAAAAH8AAPgAAAAAPwAA/AAAAAA/AAA8AAAAAD8AAAAAAAAAHwAAAAAAAAAfAAAAAAAAAA8AABgAAAAADwAAAAAAAAAHAAAAAAAAAAcAAAAAAAAABwAAAAAAAAADAAAAAAAAAAMAAADAAAAAAQAAw8AAAAABAAD/4AAAAAAAAP/wAAAAAAAA//AAAAAAAAD/8AAAAAAAAP/4AAAAAAAA//gAAAADAAD/+AAAAA8AAP/8AAAAfwAA//wAAAH/AAD//gAAB/8AAP/+AAA//wAA//8AAP//AAD//wAD//8AAP//AB///wAA//+Af///AAD//4P///8AAP//z////wAA////////AAD///////8AACgAAAAgAAAAQAAAAAEAIAAAAAAAgBAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAMsz/JDLM/4IyzP+zMsz/DQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAyzP8DMsz/QjLM/6AyzP/tMsz//zLM//8yzP9SAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAyzP8SMsz/YzLM/8EyzP/+Msz//zLM//8yzP//Msz//zLM/7MAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAyzP8oMsz/gTLM/9oyzP//Msz//zLM//8yzP//Msz//zLM//8yzP//Msz/9zLM/zAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAADLM/wYyzP9EMsz/ojLM/+8yzP//Msz//zLM//8yzP//Msz//zLM//8yzP//Msz//zLM//8yzP//Msz/kQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAADLM/xYyzP9mMsz/xDLM//8yzP//Msz//zLM//8yzP//Msz//zLM//8yzP//Msz//zLM//8yzP//Msz//zLM//8yzP/pMsz/GgAAAAAAAAAAAAAAAAAA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
// ==/UserScript==

var sciHubBaseUrl = 'https://sci-hub.ee/'; // Set sci-hub url
// Visit this url to find out latest Sci-Hub url:
// 查找最新的 Sci-Hub 网址：
// http://lovescihub.wordpress.com

// 备用网站
// http://doi.qqsci.com/
// http://tool.yovisun.com/scihub/

// The latest Sci-Hub working domain(Last check time:Sat, 13 Mar 2021 08:20:02 GMT)
// 推荐使用以下网址：

// http://sci-hub.ee 0.02s
// https://sci-hub.ee 0.03s
// https://sci-hub.st 0.31s
// https://sci-hub.do 0.36s
// https://sci-hub.se 0.36s
// http://sci-hub.ai 0.57s
// https://sci-hub.ai 1.02s

var unpaywallBaseUrl = 'https://unpaywall.org/';

var vipMirrorBaseUrl = ''; // Set vip mirror url 设置维普镜像网址 http://vip.sample.org.cn
var wanfangMirrorBaseUrl = ''; // Set vip mirror url 设置万方镜像网址 http://wanfang.sample.org.cn
var isCnkiUser = 0; // 知网用户请设为 1
var vipAutoDownload = 1; // 维普自动下载

var site = document.URL.toString();
var article_title;

var sci_hub_ico = "data:image/x-icon;base64,AAABAAcAMDAAAAEACACoDgAAdgAAACAgAAABAAgAqAgAAB4PAAAQEAAAAQAIAGgFAADGFwAAAAAAAAEAIABkegAALh0AADAwAAABACAAqCUAAJKXAAAgIAAAAQAgAKgQAAA6vQAAEBAAAAEAIABoBAAA4s0AACgAAAAwAAAAYAAAAAEACAAAAAAAAAkAAAAAAAAAAAAAAAEAAAABAAAAAAAAACrIAAAuygAAMcoAAzTLAAQ1ywAAMswAATXMAAU2zAACOc0ABDnNAAU9zwAJOc0ADDvOABA+zgAFP9AAEkHPABVCzwAXRM8ABUHQAAZF0QAIRdEAB0nTAAhJ0wAIS9QACU3UABtH0QAKUNUADFPWAAxV1gAMVtgADVnYAA5d2QAQXtoAIk7SACZQ0gAtV9UAMFjUADRb1QAPYNoAEGHaABFl3AASad0AFGjdABNs3QAUbt8AFXDfAChm2gA9ZNgAFXHgABZ14QAXeeIAGHviABh94gAef+MAGX3kAEFn2QBJbdoATnDaAFBy2wBXeN0AXn3eABqB5QAcguQAHIXmAB2I5wAdiugAHo3pAB+Q6gAgkuoAIJTrACGW7AAhmewAI5ztACSf7gA0nusAMKbuACSh8AAmpfAAJ6nyACiq8gAorfIAKa70ACmx8wAqsvUAK7X2ACy39QAsufYALLr4AC69+AAxvPcAZILfAEuE4gBcg+AAaYbgAHmT4wB7lOQAL8H5ADDD+gAwxfoAMMb8ADHI+wAyyv0ANMv+ADLM/gA1zP4AOs3+AD3N/gA00P4AQc7+AEPQ/wBF0P8ASdD+AE3R/gBR0v4AVtT+AFrV/gBe1v4AYtf+AG/U+QBj2P8Aatn+AG/b/wBx2/4Ac9z/AHXc/gB53f4Aft7+AIPe/QCF4P4AiOD+AI3i/gCR4/4AluT+AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAD///8AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAIR+AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAB+a2lrAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAdGlpaWlphAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAgm5paWlpaWlpcQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAHpraWlpaWlpaWlpaQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAB0aWlpaWlpaWlpaWlpaXYAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACEbmlpaWlpaWlpaWlpaWlpaWsAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAemtpaWlpaWlpaWlpaWlpaWlpaWl+AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAHRpaWlpaWlpaWlpaWlpaWlpaWlpaWlrAAAAAAAAAAAAAAAAAAAAAAAAAAAAAH9taWlpaWlpaWlpaWlpaWlpaWlpaWlpaWlphAAA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AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAADPM/w4zzP9OM8z/rjLL/vAzzP/9M8z/9DLL/i4AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAyy/4ZMsv+bDLL/swyy/75Msv+/jLL/v4yy/7+Msv+/jLL/owyy/4BAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAzzP8FMsv+NzPM/5YzzP/qMsv+/jPM//8zzP//M8z//zLL/v4zzP//M8z//zLL/t4zzP8aAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAMsv+DTPM/1AzzP+zMsv+8TPM//4zzP//Msv+/jPM//8zzP//M8z//zLL/v4zzP//M8z//zLL/vszzP9oAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAADLL/hoyy/5wMsv+zDLL/vgyy/7+Msv+/jLL/v4yy/7+Msv+/jLL/v4yy/7+Msv+/jLL/v4yy/7+Msv+/jLL/v4yy/7DMsv+CgAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAADPM/wgzzP84Msv+lDPM/+gzzP/+Msv+/jPM//8zzP//Msv+/jPM//8zzP//Msv+/jPM//8zzP//M8z//zLL/v4zzP//M8z//zLL/v4zzP/1M8z/SAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAADPM/wEzzP8TMsv+VjPM/7kzzP/vMsv+/jPM//8zzP//Msv+/jPM//8zzP//Msv+/jPM//8zzP//Msv+/jPM//8zzP//M8z//zLL/v4zzP//M8z//zLL/v4zzP/+M8z/rTLL/gMAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAzzP8BMsv+HjPM/3szzP/QMsv++jPM//8zzP//Msv+/jPM//8zzP//Msv+/jPM//8zzP//Msv+/jPM//8zzP//Msv+/jPM//8zzP//M8z//zLL/v4zzP//M8z//zLL/v4zzP//M8z/9DLL/igAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAMsv+BTLL/j4yy/6gMsv+7TLL/v4yy/7+Msv+/jLL/v4yy/7+Msv+/jLL/v4yy/7+Msv+/jLL/v4yy/7+Msv+/jLL/v4yy/7+Msv+/jLL/v4yy/7+Msv+/jLL/v4yy/7+Msv+/jLL/v4yy/7+Msv+/jLL/ocyy/4CAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAADPM/xQzzP9ZM8z/uDLL/vIzzP/+Msv+/jPM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/v4yy/7yMsv+ujLL/lYyy/4OAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAMsv+ATPM/8IzzP//Msv+/jPM//8zzP//Msv+/jPM//8zzP//Msv+/jPM//8zzP//Msv+/jPM//8zzP//Msv+/jPM//8zzP//M8z//zLL/v4zzP/8M8z/5TLL/pczzP85M8z/CgAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAADPM/1szzP/7Msv+/jPM//8zzP//Msv+/jPM//8zzP//Msv+/jPM//8zzP//Msv+/jPM//8zzP//Msv+/jPM//8zzP//M8z/+zLL/tAzzP93M8z/JDLL/gIAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAADLL/hMyy/7YMsv+/jLL/v4yy/7+Msv+/jLL/v4yy/7+Msv+/jLL/v4yy/7+Msv+/jLL/v4yy/7+Msv+/jLL/u4yy/6tMsv+SzLL/goAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAzzP9/Msv+/jPM//8zzP//Msv+/jPM//8zzP//Msv+/jPM//8zzP//Msv+/jPM//wzzP/fMsv+jjPM/zAzzP8GAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAzzP8qMsv+7TPM//8zzP//Msv+/jPM//8zzP//Msv+/jPM//8zzP/9Msv+0TPM/2szzP8dMsv+AQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAyy/4EMsv+pjLL/v4yy/7+Msv+/jLL/v4yy/7+Msv+7zLL/qsyy/5LMsv+CQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAMsv+QzPM//0zzP//Msv+/DPM/90zzP+KMsv+MDPM/wUAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAMsv+BjPM/8wzzP/NMsv+azPM/xcAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAADLL/hcyy/4EAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAP///////wAA////////AAD///////8AAP////+H/wAA/////Af/AAD////wA/8AAP///4AD/wAA///+AAP/AAD///gAAf8AAP//wAAB/wAA//4AAAD/AAD/+AAAAP8AAP/gAAAAfwAA/4AAAAB/AAD+AAAAAH8AAPgAAAAAPwAA/AAAAAA/AAA8AAAAAD8AAAAAAAAAHwAAAAAAAAAfAAAAAAAAAA8AABgAAAAADwAAAAAAAAAHAAAAAAAAAAcAAAAAAAAABwAAAAAAAAADAAAAAAAAAAMAAADAAAAAAQAAw8AAAAABAAD/4AAAAAAAAP/wAAAAAAAA//AAAAAAAAD/8AAAAAAAAP/4AAAAAAAA//gAAAADAAD/+AAAAA8AAP/8AAAAfwAA//wAAAH/AAD//gAAB/8AAP/+AAA//wAA//8AAP//AAD//wAD//8AAP//AB///wAA//+Af///AAD//4P///8AAP//z////wAA////////AAD///////8AACgAAAAgAAAAQAAAAAEAIAAAAAAAgBAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAMsz/JDLM/4IyzP+zMsz/DQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAyzP8DMsz/QjLM/6AyzP/tMsz//zLM//8yzP9SAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAyzP8SMsz/YzLM/8EyzP/+Msz//zLM//8yzP//Msz//zLM/7MAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAyzP8oMsz/gTLM/9oyzP//Msz//zLM//8yzP//Msz//zLM//8yzP//Msz/9zLM/zAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAADLM/wYyzP9EMsz/ojLM/+8yzP//Msz//zLM//8yzP//Msz//zLM//8yzP//Msz//zLM//8yzP//Msz/kQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAADLM/xYyzP9mMsz/xDLM//8yzP//Msz//zLM//8yzP//Msz//zLM//8yzP//Msz//zLM//8yzP//Msz//zLM//8yzP/pMsz/GgAAAAAAAAAAAAAAAAAA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";

var unpaywall_ico = "data:image/x-icon;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAAGXRFWHRTb2Z0d2FyZQBBZG9iZSBJbWFnZVJlYWR5ccllPAAAA2ZpVFh0WE1MOmNvbS5hZG9iZS54bXAAAAAAADw/eHBhY2tldCBiZWdpbj0i77u/IiBpZD0iVzVNME1wQ2VoaUh6cmVTek5UY3prYzlkIj8+IDx4OnhtcG1ldGEgeG1sbnM6eD0iYWRvYmU6bnM6bWV0YS8iIHg6eG1wdGs9IkFkb2JlIFhNUCBDb3JlIDUuMC1jMDYwIDYxLjEzNDc3NywgMjAxMC8wMi8xMi0xNzozMjowMCAgICAgICAgIj4gPHJkZjpSREYgeG1sbnM6cmRmPSJodHRwOi8vd3d3LnczLm9yZy8xOTk5LzAyLzIyLXJkZi1zeW50YXgtbnMjIj4gPHJkZjpEZXNjcmlwdGlvbiByZGY6YWJvdXQ9IiIgeG1sbnM6eG1wTU09Imh0dHA6Ly9ucy5hZG9iZS5jb20veGFwLzEuMC9tbS8iIHhtbG5zOnN0UmVmPSJodHRwOi8vbnMuYWRvYmUuY29tL3hhcC8xLjAvc1R5cGUvUmVzb3VyY2VSZWYjIiB4bWxuczp4bXA9Imh0dHA6Ly9ucy5hZG9iZS5jb20veGFwLzEuMC8iIHhtcE1NOk9yaWdpbmFsRG9jdW1lbnRJRD0ieG1wLmRpZDpGRTdGMTE3NDA3MjA2ODExQkE4RkU5MENBRDI2MzE2OSIgeG1wTU06RG9jdW1lbnRJRD0ieG1wLmRpZDoxMTY3RkU3MkZCMDUxMUU2QjNCMUY3NEM1Q0MyMEFDQyIgeG1wTU06SW5zdGFuY2VJRD0ieG1wLmlpZDoxMTY3RkU3MUZCMDUxMUU2QjNCMUY3NEM1Q0MyMEFDQyIgeG1wOkNyZWF0b3JUb29sPSJBZG9iZSBQaG90b3Nob3AgQ1M1IE1hY2ludG9zaCI+IDx4bXBNTTpEZXJpdmVkRnJvbSBzdFJlZjppbnN0YW5jZUlEPSJ4bXAuaWlkOjAwODAxMTc0MDcyMDY4MTFCQThGRTkwQ0FEMjYzMTY5IiBzdFJlZjpkb2N1bWVudElEPSJ4bXAuZGlkOkZFN0YxMTc0MDcyMDY4MTFCQThGRTkwQ0FEMjYzMTY5Ii8+IDwvcmRmOkRlc2NyaXB0aW9uPiA8L3JkZjpSREY+IDwveDp4bXBtZXRhPiA8P3hwYWNrZXQgZW5kPSJyIj8+t6vfrwAAANpJREFUeNpi/P//PwMyUHyU6Qak3IHYCog1gZifAQ9gQdKoAKRygDgdiHkYiAQsSJqbgTiGgUQAc0EOumZmBiaGeWLZDHYcWmD+oR/XGOJfTcYwgAnq53R0CWTNIABiLxTLxTQAGmAYfoZpBloAxshi6F6wIsavMEOwuUCTgQLAgk3wvtx0rGxsrgG54DolLgAZcIxSA3YC8RdyDWAE5QWgn3qA7GKYoDm7KoMFhxpWDSd+3GI4+fM2RiBOAWJxWGoEKUBWRMgLoJB+AKRqgbiXVO8wUpqdAQIMAORQP6fYI7qnAAAAAElFTkSuQmCC";

var cnki_ico = "data:image/x-icon;base64,AAABAAEAEBAAAAEAIABoBAAAFgAAACgAAAAQAAAAIAAAAAEAIAAAAAAAQAQAAAAAAAAAAAAAAAAAAAAAAAA/h///P4f//z+H//8/h///P4f//z+H//8/h///P4f//z+H//8/h///P4f//z+H//8/h///P4f//z+H//8/h///P4f////////R0dH/Y2Nj/0ZGRv/o6Oj//////6mpqf+wsLD//f39////////////////////////////P4f//z+H/////////////+bm5v9ISEj/f39//+fn5/8HBwf/V1dX//n5+f///////////////////////////z+H//8/h/////////Hx8f//////6urq/1BQUP+FhYX/WFhY/9ra2v//////6urq//T09P////////////////8/h///P4f//+Xl5f9NTU3/YmJi/9jY2P+Hh4f/oqKi//7+/v//////39/f/zo6Ov9ERET/l5eX/9nZ2f/9/f3/P4f//z+H///m5ub/FhYW/xAQEP9DQ0P/ISEh/3d3d//q6ur//v7+/3Jycv8tLS3/f39//wMDA/9QUFD/8vLy/z+H//8/h////////9TU1P+6urr/wsLC/1lZWf8AAAD/Pj4+/9zc3P9LS0v/dXV1//////+dnZ3/VVVV//v7+/8/h///P4f///////////////////T09P+SkpL/Hx8f/6enp//f39//HBwc/2hoaP/4+Pj/+fn5/1RUVP/CwsL/P4f//z+H/////////////9ra2v+RkZH/IyMj/yEhIf/W1tb/+Pj4/6SkpP+Ojo7/Z2dn/42Njf8wMDD/Q0ND/z+H//8/h/////////////+EhIT/AAAA/wAAAP8AAAD/Ghoa/7e3t///////+/v7/8bGxv90dHT/NDQ0/4CAgP8/h///P4f/////////////6urq/y8vL/8RERH/Y2Nj/xAQEP8SEhL/2dnZ/////////////////+bm5v/z8/P/P4f//z+H//////////////////+1tbX/BgYG/8jIyP/Kysr/dXV1/+fn5////////////////////////////z+H//8/h///////////////////5+fn/xQUFP9MTEz/6urq//////////////////////////////////////8/h///P4f//////////////////+rq6v8oKCj/AgIC/6Ghof//////////////////////////////////////P4f//z+H///////////////////x8fH/Z2dn/3d3d//z8/P//////////////////////////////////////z+H//8/h///P4f//z+H//8/h///P4f//z+H//8/h///P4f//z+H//8/h///P4f//z+H//8/h///P4f//z+H//8/h///AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA==";

var vip_ico = "data:image/x-icon;base64,AAABAAEAEBAAAAEAIABoBAAAFgAAACgAAAAQAAAAIAAAAAEAIAAAAAAAQAQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAFDue/xQ7nv8UO57/FDue/xQ7nv8UO57/FDue/xQ7nv8UO57/FDue/xQ7nv8UO57/FDue/xQ7nv8AAAAAgpfz/yQk3f8kJN3/JCTd/yQk3f8kJN3/JCTd/1JS5P9xcen/JCTd/yQk3f8kJN3/JCTd/yQk3f8kJN3/FDue/4KX8/8kJN3/JCTd/yQk3f8kJN3/JCTd/yQk3f+5ufT/29v5/ycn3f8kJN3/JCTd/yQk3f8kJN3/JCTd/xQ7nv+Cl/P/JCTd/yQk3f8kJN3/JCTd/yQk3f9LS+P/8vLy//Ly8v9xcen/JCTd/yQk3f8kJN3/JCTd/yQk3f8UO57/gpfz/yQk3f8kJN3/JCTd/yQk3f8kJN3/JCTd/yQk3f8kJN3/JCTd/yQk3f8kJN3/JCTd/yQk3f8kJN3/FDue/4KX8/8mK9//Jivf/yYr3/8lK9//Rkvk//Ly8v/y8vL/8vLy//Ly8v9zdur/JSvf/yUr3/8mKt//Jivg/xQ7nv+Cl/P/JzXj/yc14v8oNuL/KDXi/yg24/8oNeL/KDXi/yg14v8oNeL/JzXi/yg14v8oNeL/KDXi/yg14v8UO57/gpfz/ypB5v8qQOX/KkDm/0NX6f/y8vL/8vLy//Ly8v/y8vL/8vLy//Ly8v94hu//KkHm/ytB5v8qQeb/FDue/4KX8/8sS+n/LUvp/yxL6f8sS+n/LEvp/yxL6f8sS+n/LEvp/yxL6f8sS+n/LUvp/yxL6f8sS+n/LEvp/xQ7nv+Cl/P/LlLr/y5S6/9CYu3/4OLr/5Cj9P8uUuv/ztb6/+Di6/////////////////99k/P/LlLr/y5S6/8UO57/gpfz/y5S6/8uUuv/orL2///////m6/3/MFTr/1157//Z2dn/8vLy////////////3+X8/zBU6/8uUuv/FDue/4KX8/8uUuv/P2Dt/+Di6////////////3iP8v8uUuv/usb4/9nZ2f////////////////99k/P/LlLr/xQ7nv+Cl/P/LlLr/5iq9f/////////////////Y3vv/LlLr/0xq7v/Z2dn/8vLy////////////4ef8/zBU6/8UO57/gpfz/zpc7P/g4uv//////////////////////2mD8f8uUuv/qbj3/9nZ2f////////////////99k/P/FDue/4KX8/+TpfX/2dnZ/9nZ2f/Z2dn/2dnZ/9nZ2f/J0vr/LlLr/0Ji7f/Z2dn/2dnZ//Dz/v/V3Pv/usb4/xQ7nv8AAAAAgpfz/4KX8/+Cl/P/gpfz/4KX8/+Cl/P/gpfz/4KX8/+Cl/P/gpfz/4KX8/+Cl/P/gpfz/4KX8/8AAAAAgAEAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAgAEAAA==";

var wanfang_ico = "data:image/x-icon;base64,AAABAAQAEBAAAAEAIABoBAAARgAAABgYAAABACAAiAkAAK4EAAAgIAAAAQAgAKgQAAA2DgAAMDAAAAEAIACoJQAA3h4AACgAAAAQAAAAIAAAAAEAIAAAAAAAQAQAAAAAAAAAAAAAAAAAAAAAAAAAAP//AAD//wAA//8AAP//AAD//wAA//8AAP//AAD//wAA//8AAP//AAD//wAA//8AAP//AAD//wAA//8AAP//AAD//////+L/////////////////////////4g0N///////i///////////////////////////////iAAD//wAA////////////4v///+L////i////4v////8UFP///////////+L////////////////////i/////wAA//8AAP//////////////////////////////////FBT////////////////////////////i////xv////8AAP//AAD//////////////////////////////////xQU/////////////////+L//////////////8b/////AAD//wAA//////////////////////////////////8UFP///////////+L////////////////////G/////wAA//8AAP//////////////////////////////////FBT//////+L////////////////////i////4v///+IAAP//AAD//////////////////////////////////xIS///////G/////////////////////////+L///+NAAD//wAA//////////////////////////////////8AAP//AAD//wAA//8AAP//AAD//wAA//8AAP//AAD//wAA//8AAP//////////////////////////////////DQ3//////+L//////////////////////////////+IAAP//AAD////////////////////////////i/////xQU////////////4v///+L////i/////////+L/////AAD//wAA////////////4v////////////////////8UFP/////////////////i/////////////////////wAA//8AAP///////////8b/////////////////////FBT/////////////////4v/////////i//////////8AAP//AAD//////+L////////////////////G/////xQU///////i/////////////////////////+L/////AAD//wAA///////G/////////////////////////+IODv//////xv//////////////////////////////4gAA//8AAP//AAD//wAA//8AAP//AAD//wAA//8AAP//AAD//wAA//8AAP//AAD//wAA//8AAP//AAD//wAA//8AAP//AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACgAAAAYAAAAMAAAAAEAIAAAAAAAYAkAAAAAAAAAAAAAAAAAAAAAAAAAAP//AAD//wAA//8AAP//AAD//wAA//8AAP//AAD//wAA//8AAP//AAD//wAA//8AAP//AAD//wAA//8AAP//AAD//wAA//8AAP//AAD//wAA//8AAP//AAD//wAA//8AAP//AAD+/gAA/v4AAP//AAD+/gAA//8AAP7+AAD+/gAA/v4AAP//AAD+/gAA/v4AAP//AAD+/gAA/v4AAP//AAD+/gAA/v4AAP//AAD+/gAA//8AAP7+AAD+/gAA/v4AAP//MDD+/vT0/v709P//9PT+/vT0///09P7+9PT+/vT0/v709P//ExP+/h0d/v709P//9PT+/vT0/v709P//9PT+/vT0/v709P//9PT+/vT0///09P7+HR3+/gAA/v4AAP//MzP/////////////////////////////////////////////FBT//x4e////////////////////////////////////////////////////////Hx///wAA//8AAP//MzP+/v7+/v7//////v7+/v/////+/v7+/v7+/v7+/v7/////FBT+/h4e/v7//////v7+/v7+/v7//////v7+/v7+/v7//////v7+/v/////+/v7+Hx/+/gAA/v4AAP//MzP/////////////////////////////////////////////FBT//x4e////////////////////////////////////////////////////////Hx///wAA//8AAP//MzP+/v7+/v7//////v7+/v/////+/v7+/v7+/v7+/v7/////FBT+/h4e/v7//////v7+/v7+/v7//////v7+/v7+/v7//////v7+/v/////+/v7+Hx/+/gAA/v4AAP//MzP+/v7+/v7//////v7+/v/////+/v7+/v7+/v7+/v7/////FBT+/h4e/v7//////v7+/v7+/v7//////v7+/v7+/v7//////v7+/v/////+/v7+Hx/+/gAA/v4AAP//MzP+/v7+/v7//////v7+/v/////+/v7+/v7+/v7+/v7/////FBT+/h4e/v7//////v7+/v7+/v7//////v7+/v7+/v7//////v7+/v/////+/v7+Hx/+/gAA/v4AAP//MzP/////////////////////////////////////////////FBT//x4e////////////////////////////////////////////////////////Hx///wAA//8AAP//MzP+/v7+/v7//////v7+/v/////+/v7+/v7+/v7+/v7/////FBT+/h4e/v7//////v7+/v7+/v7//////v7+/v7+/v7//////v7+/v/////+/v7+Hx/+/gAA/v4AAP//MzP+/v7+/v7//////v7+/v/////+/v7+/v7+/v7+/v7/////FBT+/hoa/v7g4P//4OD+/uDg/v7g4P//4OD+/uDg/v7g4P//4OD+/uDg///g4P7+Ghr+/gAA/v4AAP//MzP/////////////////////////////////////////////FBT//wAA//8AAP//AAD//wAA//8AAP//AAD//wAA//8AAP//AAD//wAA//8AAP//AAD//wAA//8AAP//MzP+/v7+/v7//////v7+/v/////+/v7+/v7+/v7+/v7/////FBT+/gAA/v4AAP//AAD+/gAA/v4AAP//AAD+/gAA/v4AAP//AAD+/gAA//8AAP7+AAD+/gAA/v4AAP//MzP+/v7+/v7//////v7+/v/////+/v7+/v7+/v7+/v7/////FBT+/h0d/v709P//9PT+/vT0/v709P//9PT+/vT0/v709P//9PT+/vT0///09P7+HR3+/gAA/v4AAP//MzP/////////////////////////////////////////////FBT//x4e////////////////////////////////////////////////////////Hx///wAA//8AAP//MzP+/v7+/v7//////v7+/v/////+/v7+/v7+/v7+/v7/////FBT+/h4e/v7//////v7+/v7+/v7//////v7+/v7+/v7//////v7+/v/////+/v7+Hx/+/gAA/v4AAP//MzP+/v7+/v7//////v7+/v/////+/v7+/v7+/v7+/v7/////FBT+/h4e/v7//////v7+/v7+/v7//////v7+/v7+/v7//////v7+/v/////+/v7+Hx/+/gAA/v4AAP//MzP/////////////////////////////////////////////FBT//x4e////////////////////////////////////////////////////////Hx///wAA//8AAP//MzP+/v7+/v7//////v7+/v/////+/v7+/v7+/v7+/v7/////FBT+/h4e/v7//////v7+/v7+/v7//////v7+/v7+/v7//////v7+/v/////+/v7+Hx/+/gAA/v4AAP//MzP/////////////////////////////////////////////FBT//x4e////////////////////////////////////////////////////////Hx///wAA//8AAP//MzP+/v7+/v7//////v7+/v/////+/v7+/v7+/v7+/v7/////FBT+/h4e/v7//////v7+/v7+/v7//////v7+/v7+/v7//////v7+/v/////+/v7+Hh7+/gAA/v4AAP//BAT+/hQU/v4UFP//FBT+/hQU//8UFP7+FBT+/hQU/v4UFP//AQH+/gIC/v4UFP//FBT+/hQU/v4UFP//FBT+/hQU/v4UFP//FBT+/hQU//8UFP7+AgL+/gAA/v4AAP//AAD+/gAA/v4AAP//AAD+/gAA//8AAP7+AAD+/gAA/v4AAP//AAD+/gAA/v4AAP//AAD+/gAA/v4AAP//AAD+/gAA/v4AAP//AAD+/gAA//8AAP7+AAD+/gAA/v4AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAoAAAAIAAAAEAAAAABACAAAAAAAIAQAAAAAAAAAAAAAAAAAAAAAAAAAAD//wAA//8AAP//AAD//wAA//8AAP//AAD//wAA//8AAP//AAD//wAA//8AAP//AAD//wAA//8AAP//AAD//wAA//8AAP//AAD//wAA//8AAP//AAD//wAA//8AAP//AAD//wAA//8AAP//AAD//wAA//8AAP//AAD//wAA//8AAP//AAD//wAA//8AAP//AAD//wAA//8AAP//AAD//wAA//8AAP//AAD//wAA//8AAP//AAD//wAA//8AAP//AAD//wAA//8AAP//AAD//wAA//8AAP//AAD//wAA//8AAP//AAD//wAA//8AAP//AAD//wAA//8AAP//AAD//wAA//8AAP//Kir//0dH//9HR///R0f//0dH//9HR///R0f//0dH//9HR///R0f//0dH//8fH///AAD//wsL//9HR///R0f//0dH//9HR///R0f//0dH//9HR///R0f//0dH//9HR///R0f//0dH//9HR///IiL//wAA//8AAP//AAD//wAA//+Zmf///////////////////////////////////////////////////////3Bw//8AAP//KCj///////////////////////////////////////////////////////////////////////9/f///AAD//wAA//8AAP//AAD//5mZ////////////////////////////////////////////////////////cHD//wAA//8oKP///////////////////////////////////////////////////////////////////////35+//8AAP//AAD//wAA//8AAP//mZn///////////////////////////////////////////////////////9wcP//AAD//ygo////////////////////////////////////////////////////////////////////////fn7//wAA//8AAP//AAD//wAA//+Zmf///////////////////////////////////////////////////////3Bw//8AAP//KCj///////////////////////////////////////////////////////////////////////9+fv//AAD//wAA//8AAP//AAD//5mZ////////////////////////////////////////////////////////cHD//wAA//8oKP///////////////////////////////////////////////////////////////////////35+//8AAP//AAD//wAA//8AAP//mZn///////////////////////////////////////////////////////9wcP//AAD//ygo////////////////////////////////////////////////////////////////////////fn7//wAA//8AAP//AAD//wAA//+Zmf///////////////////////////////////////////////////////3Bw//8AAP//KCj///////////////////////////////////////////////////////////////////////9+fv//AAD//wAA//8AAP//AAD//5mZ////////////////////////////////////////////////////////cHD//wAA//8oKP///////////////////////////////////////////////////////////////////////35+//8AAP//AAD//wAA//8AAP//mZn///////////////////////////////////////////////////////9wcP//AAD//ygo////////////////////////////////////////////////////////////////////////fn7//wAA//8AAP//AAD//wAA//+Zmf///////////////////////////////////////////////////////3Bw//8AAP//KCj///////////////////////////////////////////////////////////////////////9+fv//AAD//wAA//8AAP//AAD//5mZ////////////////////////////////////////////////////////cHD//wAA//8oKP///////////////////////////////////////////////////////////////////////35+//8AAP//AAD//wAA//8AAP//mZn///////////////////////////////////////////////////////9wcP//AAD//ygo////////////////////////////////////////////////////////////////////////fn7//wAA//8AAP//AAD//wAA//+Zmf///////////////////////////////////////////////////////3Bw//8AAP//IiL//9bW///W1v//1tb//9bW///W1v//1tb//9bW///W1v//1tb//9bW///W1v//1tb//9bW//9oaP//AAD//wAA//8AAP//AAD//5mZ////////////////////////////////////////////////////////cHD//wAA//8AAP//AAD//wAA//8AAP//AAD//wAA//8AAP//AAD//wAA//8AAP//AAD//wAA//8AAP//AAD//wAA//8AAP//AAD//wAA//8AAP//mZn///////////////////////////////////////////////////////9wcP//AAD//wAA//8AAP//AAD//wAA//8AAP//AAD//wAA//8AAP//AAD//wAA//8AAP//AAD//wAA//8AAP//AAD//wAA//8AAP//AAD//wAA//+Zmf///////////////////////////////////////////////////////3Bw//8AAP//Cwv//0dH//9HR///R0f//0dH//9HR///R0f//0dH//9HR///R0f//0dH//9HR///R0f//0dH//8iIv//AAD//wAA//8AAP//AAD//5mZ////////////////////////////////////////////////////////cHD//wAA//8oKP///////////////////////////////////////////////////////////////////////39///8AAP//AAD//wAA//8AAP//mZn///////////////////////////////////////////////////////9wcP//AAD//ygo////////////////////////////////////////////////////////////////////////fn7//wAA//8AAP//AAD//wAA//+Zmf///////////////////////////////////////////////////////3Bw//8AAP//KCj///////////////////////////////////////////////////////////////////////9+fv//AAD//wAA//8AAP//AAD//5mZ////////////////////////////////////////////////////////cHD//wAA//8oKP///////////////////////////////////////////////////////////////////////35+//8AAP//AAD//wAA//8AAP//mZn///////////////////////////////////////////////////////9wcP//AAD//ygo////////////////////////////////////////////////////////////////////////fn7//wAA//8AAP//AAD//wAA//+Zmf///////////////////////////////////////////////////////3Bw//8AAP//KCj///////////////////////////////////////////////////////////////////////9+fv//AAD//wAA//8AAP//AAD//5mZ////////////////////////////////////////////////////////cHD//wAA//8oKP///////////////////////////////////////////////////////////////////////35+//8AAP//AAD//wAA//8AAP//mZn///////////////////////////////////////////////////////9wcP//AAD//ygo////////////////////////////////////////////////////////////////////////fn7//wAA//8AAP//AAD//wAA//+Zmf///////////////////////////////////////////////////////3Bw//8AAP//KCj///////////////////////////////////////////////////////////////////////9+fv//AAD//wAA//8AAP//AAD//5mZ////////////////////////////////////////////////////////cHD//wAA//8oKP///////////////////////////////////////////////////////////////////////39///8AAP//AAD//wAA//8AAP//Q0P//3Bw//9wcP//cHD//3Bw//9wcP//cHD//3Bw//9wcP//cHD//3Bw//8xMf//AAD//xER//9wcP//cHD//3Bw//9wcP//cHD//3Bw//9wcP//cHD//3Bw//9wcP//cHD//3Bw//9wcP//NTX//wAA//8AAP//AAD//wAA//8AAP//AAD//wAA//8AAP//AAD//wAA//8AAP//AAD//wAA//8AAP//AAD//wAA//8AAP//AAD//wAA//8AAP//AAD//wAA//8AAP//AAD//wAA//8AAP//AAD//wAA//8AAP//AAD//wAA//8AAP//AAD//wAA//8AAP//AAD//wAA//8AAP//AAD//wAA//8AAP//AAD//wAA//8AAP//AAD//wAA//8AAP//AAD//wAA//8AAP//AAD//wAA//8AAP//AAD//wAA//8AAP//AAD//wAA//8AAP//AAD//wAA//8AAP//AAD//wAA//8AAP//AAD//wAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAKAAAADAAAABgAAAAAQAgAAAAAACAJQAAAAAAAAAAAAAAAAAAAAAAAAAA//8AAP//AAD+/gAA//8AAP//AAD//wAA/v4AAP//AAD+/gAA//8AAP//AAD+/gAA//8AAP//AAD+/gAA//8AAP//AAD+/gAA//8AAP//AAD//wAA/v4AAP//AAD//wAA/v4AAP//AAD//wAA/v4AAP//AAD//wAA/v4AAP//AAD//wAA/v4AAP//AAD+/gAA//8AAP//AAD+/gAA//8AAP//AAD+/gAA//8AAP//AAD+/gAA//8AAP//AAD+/gAA//8AAP//AAD+/gAA//8AAP//AAD//wAA/v4AAP//AAD+/gAA//8AAP//AAD+/gAA//8AAP//AAD+/gAA//8AAP//AAD+/gAA//8AAP//AAD//wAA/v4AAP//AAD//wAA/v4AAP//AAD//wAA/v4AAP//AAD//wAA/v4AAP//AAD//wAA/v4AAP//AAD+/gAA//8AAP//AAD+/gAA//8AAP//AAD+/gAA//8AAP//AAD+/gAA//8AAP//AAD+/gAA/v4AAP7+AAD+/gAA/v4AAP7+AAD+/gAA/v4AAP7+AAD+/gAA/v4AAP7+AAD+/gAA/v4AAP7+AAD+/gAA/v4AAP7+AAD+/gAA/v4AAP7+AAD+/gAA/v4AAP7+AAD+/gAA/v4AAP7+AAD+/gAA/v4AAP7+AAD+/gAA/v4AAP7+AAD+/gAA/v4AAP7+AAD+/gAA/v4AAP7+AAD+/gAA/v4AAP7+AAD+/gAA/v4AAP7+AAD+/gAA/v4AAP7+AAD+/gAA//8AAP//AAD+/gAA//8AAP//AAD//wAA/v4AAP//AAD+/gAA//8AAP//AAD+/gAA//8AAP//AAD+/gAA//8AAP//AAD+/gAA//8AAP//AAD//wAA/v4AAP//AAD//wAA/v4AAP//AAD//wAA/v4AAP//AAD//wAA/v4AAP//AAD//wAA/v4AAP//AAD+/gAA//8AAP//AAD+/gAA//8AAP//AAD+/gAA//8AAP//AAD+/gAA//8AAP//AAD+/gAA//8AAP//AAD+/l1d///q6v//6ur//+rq/v7q6v//6ur+/urq///q6v//6ur+/urq///q6v//6ur+/urq///q6v//6ur+/urq///q6v//JSX//wAA/v4AAP//ODj//+rq/v7q6v//6ur//+rq/v7q6v//6ur//+rq/v7q6v//6ur//+rq/v7q6v//6ur+/urq///q6v//6ur+/urq///q6v//6ur+/urq///q6v//Nzf+/gAA//8AAP//AAD+/gAA//8AAP//AAD+/mZm//////////////7+/v7//////v7+/v///////////v7+/v///////////v7+/v///////////v7+/v//////////KCj//wAA/v4AAP//PT3///7+/v7///////////7+/v7///////////7+/v7///////////7+/v7//////v7+/v///////////v7+/v///////////v7+/v//////////Pz/+/gAA//8AAP//AAD+/gAA/v4AAP7+AAD+/mZm/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+KCj+/gAA/v4AAP7+PT3+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+Pj7+/gAA/v4AAP7+AAD+/gAA//8AAP//AAD+/mZm//////////////7+/v7//////v7+/v///////////v7+/v///////////v7+/v///////////v7+/v//////////KCj//wAA/v4AAP//PT3///7+/v7///////////7+/v7///////////7+/v7///////////7+/v7//////v7+/v///////////v7+/v///////////v7+/v//////////Pj7+/gAA//8AAP//AAD+/gAA/v4AAP7+AAD+/mZm/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+KCj+/gAA/v4AAP7+PT3+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+Pj7+/gAA/v4AAP7+AAD+/gAA//8AAP//AAD+/mZm//////////////7+/v7//////v7+/v///////////v7+/v///////////v7+/v///////////v7+/v//////////KCj//wAA/v4AAP//PT3///7+/v7///////////7+/v7///////////7+/v7///////////7+/v7//////v7+/v///////////v7+/v///////////v7+/v//////////Pj7+/gAA//8AAP//AAD+/gAA//8AAP//AAD+/mZm//////////////7+/v7//////v7+/v///////////v7+/v///////////v7+/v///////////v7+/v//////////KCj//wAA/v4AAP//PT3///7+/v7///////////7+/v7///////////7+/v7///////////7+/v7//////v7+/v///////////v7+/v///////////v7+/v//////////Pj7+/gAA//8AAP//AAD+/gAA/v4AAP7+AAD+/mZm/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+KCj+/gAA/v4AAP7+PT3+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+Pj7+/gAA/v4AAP7+AAD+/gAA//8AAP//AAD+/mZm//////////////7+/v7//////v7+/v///////////v7+/v///////////v7+/v///////////v7+/v//////////KCj//wAA/v4AAP//PT3///7+/v7///////////7+/v7///////////7+/v7///////////7+/v7//////v7+/v///////////v7+/v///////////v7+/v//////////Pj7+/gAA//8AAP//AAD+/gAA//8AAP//AAD+/mZm//////////////7+/v7//////v7+/v///////////v7+/v///////////v7+/v///////////v7+/v//////////KCj//wAA/v4AAP//PT3///7+/v7///////////7+/v7///////////7+/v7///////////7+/v7//////v7+/v///////////v7+/v///////////v7+/v//////////Pj7+/gAA//8AAP//AAD+/gAA/v4AAP7+AAD+/mZm/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+KCj+/gAA/v4AAP7+PT3+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+Pj7+/gAA/v4AAP7+AAD+/gAA//8AAP//AAD+/mZm//////////////7+/v7//////v7+/v///////////v7+/v///////////v7+/v///////////v7+/v//////////KCj//wAA/v4AAP//PT3///7+/v7///////////7+/v7///////////7+/v7///////////7+/v7//////v7+/v///////////v7+/v///////////v7+/v//////////Pj7+/gAA//8AAP//AAD+/gAA//8AAP//AAD+/mZm//////////////7+/v7//////v7+/v///////////v7+/v///////////v7+/v///////////v7+/v//////////KCj//wAA/v4AAP//PT3///7+/v7///////////7+/v7///////////7+/v7///////////7+/v7//////v7+/v///////////v7+/v///////////v7+/v//////////Pj7+/gAA//8AAP//AAD+/gAA/v4AAP7+AAD+/mZm/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+KCj+/gAA/v4AAP7+PT3+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+Pj7+/gAA/v4AAP7+AAD+/gAA//8AAP//AAD+/mZm//////////////7+/v7//////v7+/v///////////v7+/v///////////v7+/v///////////v7+/v//////////KCj//wAA/v4AAP//PT3///7+/v7///////////7+/v7///////////7+/v7///////////7+/v7//////v7+/v///////////v7+/v///////////v7+/v//////////Pj7+/gAA//8AAP//AAD+/gAA//8AAP//AAD+/mZm//////////////7+/v7//////v7+/v///////////v7+/v///////////v7+/v///////////v7+/v//////////KCj//wAA/v4AAP//PT3///7+/v7///////////7+/v7///////////7+/v7///////////7+/v7//////v7+/v///////////v7+/v///////////v7+/v//////////Pj7+/gAA//8AAP//AAD+/gAA//8AAP//AAD+/mZm//////////////7+/v7//////v7+/v///////////v7+/v///////////v7+/v///////////v7+/v//////////KCj//wAA/v4AAP//PT3///7+/v7///////////7+/v7///////////7+/v7///////////7+/v7//////v7+/v///////////v7+/v///////////v7+/v//////////Pj7+/gAA//8AAP//AAD+/gAA/v4AAP7+AAD+/mZm/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+KCj+/gAA/v4AAP7+PT3+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+Pj7+/gAA/v4AAP7+AAD+/gAA//8AAP//AAD+/mZm//////////////7+/v7//////v7+/v///////////v7+/v///////////v7+/v///////////v7+/v//////////KCj//wAA/v4AAP//PT3///7+/v7///////////7+/v7///////////7+/v7///////////7+/v7//////v7+/v///////////v7+/v///////////v7+/v//////////Pz/+/gAA//8AAP//AAD+/gAA//8AAP//AAD+/mZm//////////////7+/v7//////v7+/v///////////v7+/v///////////v7+/v///////////v7+/v//////////KCj//wAA/v4AAP//Li7//8HB/v7Bwf//wcH//8HB/v7Bwf//wcH//8HB/v7Bwf//wcH//8HB/v7Bwf//wcH+/sHB///Bwf//wcH+/sHB///Bwf//wcH+/sHB///Bwf//Kir+/gAA//8AAP//AAD+/gAA/v4AAP7+AAD+/mZm/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+KCj+/gAA/v4AAP7+AAD+/gAA/v4AAP7+AAD+/gAA/v4AAP7+AAD+/gAA/v4AAP7+AAD+/gAA/v4AAP7+AAD+/gAA/v4AAP7+AAD+/gAA/v4AAP7+AAD+/gAA/v4AAP7+AAD+/gAA/v4AAP7+AAD+/gAA//8AAP//AAD+/mZm//////////////7+/v7//////v7+/v///////////v7+/v///////////v7+/v///////////v7+/v//////////KCj//wAA/v4AAP//AAD//wAA/v4AAP//AAD//wAA/v4AAP//AAD//wAA/v4AAP//AAD//wAA/v4AAP//AAD+/gAA//8AAP//AAD+/gAA//8AAP//AAD+/gAA//8AAP//AAD+/gAA//8AAP//AAD+/gAA//8AAP//AAD+/mZm//////////////7+/v7//////v7+/v///////////v7+/v///////////v7+/v///////////v7+/v//////////KCj//wAA/v4AAP//AAD//wAA/v4AAP//AAD//wAA/v4AAP//AAD//wAA/v4AAP//AAD//wAA/v4AAP//AAD+/gAA//8AAP//AAD+/gAA//8AAP//AAD+/gAA//8AAP//AAD+/gAA//8AAP//AAD+/gAA/v4AAP7+AAD+/mZm/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+KCj+/gAA/v4AAP7+AAD+/gAA/v4AAP7+AAD+/gAA/v4AAP7+AAD+/gAA/v4AAP7+AAD+/gAA/v4AAP7+AAD+/gAA/v4AAP7+AAD+/gAA/v4AAP7+AAD+/gAA/v4AAP7+AAD+/gAA/v4AAP7+AAD+/gAA//8AAP//AAD+/mZm//////////////7+/v7//////v7+/v///////////v7+/v///////////v7+/v///////////v7+/v//////////KCj//wAA/v4AAP//ODj//+rq/v7q6v//6ur//+rq/v7q6v//6ur//+rq/v7q6v//6ur//+rq/v7q6v//6ur+/urq///q6v//6ur+/urq///q6v//6ur+/urq///q6v//Nzf+/gAA//8AAP//AAD+/gAA//8AAP//AAD+/mZm//////////////7+/v7//////v7+/v///////////v7+/v///////////v7+/v///////////v7+/v//////////KCj//wAA/v4AAP//PT3///7+/v7///////////7+/v7///////////7+/v7///////////7+/v7//////v7+/v///////////v7+/v///////////v7+/v//////////Pz/+/gAA//8AAP//AAD+/gAA/v4AAP7+AAD+/mZm/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+KCj+/gAA/v4AAP7+PT3+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+Pj7+/gAA/v4AAP7+AAD+/gAA//8AAP//AAD+/mZm//////////////7+/v7//////v7+/v///////////v7+/v///////////v7+/v///////////v7+/v//////////KCj//wAA/v4AAP//PT3///7+/v7///////////7+/v7///////////7+/v7///////////7+/v7//////v7+/v///////////v7+/v///////////v7+/v//////////Pj7+/gAA//8AAP//AAD+/gAA//8AAP//AAD+/mZm//////////////7+/v7//////v7+/v///////////v7+/v///////////v7+/v///////////v7+/v//////////KCj//wAA/v4AAP//PT3///7+/v7///////////7+/v7///////////7+/v7///////////7+/v7//////v7+/v///////////v7+/v///////////v7+/v//////////Pj7+/gAA//8AAP//AAD+/gAA/v4AAP7+AAD+/mZm/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+KCj+/gAA/v4AAP7+PT3+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+Pj7+/gAA/v4AAP7+AAD+/gAA//8AAP//AAD+/mZm//////////////7+/v7//////v7+/v///////////v7+/v///////////v7+/v///////////v7+/v//////////KCj//wAA/v4AAP//PT3///7+/v7///////////7+/v7///////////7+/v7///////////7+/v7//////v7+/v///////////v7+/v///////////v7+/v//////////Pj7+/gAA//8AAP//AAD+/gAA/v4AAP7+AAD+/mZm/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+KCj+/gAA/v4AAP7+PT3+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+Pj7+/gAA/v4AAP7+AAD+/gAA//8AAP//AAD+/mZm//////////////7+/v7//////v7+/v///////////v7+/v///////////v7+/v///////////v7+/v//////////KCj//wAA/v4AAP//PT3///7+/v7///////////7+/v7///////////7+/v7///////////7+/v7//////v7+/v///////////v7+/v///////////v7+/v//////////Pj7+/gAA//8AAP//AAD+/gAA//8AAP//AAD+/mZm//////////////7+/v7//////v7+/v///////////v7+/v///////////v7+/v///////////v7+/v//////////KCj//wAA/v4AAP//PT3///7+/v7///////////7+/v7///////////7+/v7///////////7+/v7//////v7+/v///////////v7+/v///////////v7+/v//////////Pj7+/gAA//8AAP//AAD+/gAA/v4AAP7+AAD+/mZm/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+KCj+/gAA/v4AAP7+PT3+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+Pj7+/gAA/v4AAP7+AAD+/gAA//8AAP//AAD+/mZm//////////////7+/v7//////v7+/v///////////v7+/v///////////v7+/v///////////v7+/v//////////KCj//wAA/v4AAP//PT3///7+/v7///////////7+/v7///////////7+/v7///////////7+/v7//////v7+/v///////////v7+/v///////////v7+/v//////////Pj7+/gAA//8AAP//AAD+/gAA//8AAP//AAD+/mZm//////////////7+/v7//////v7+/v///////////v7+/v///////////v7+/v///////////v7+/v//////////KCj//wAA/v4AAP//PT3///7+/v7///////////7+/v7///////////7+/v7///////////7+/v7//////v7+/v///////////v7+/v///////////v7+/v//////////Pj7+/gAA//8AAP//AAD+/gAA/v4AAP7+AAD+/mZm/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+KCj+/gAA/v4AAP7+PT3+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+/v7+Pj7+/gAA/v4AAP7+AAD+/gAA//8AAP//AAD+/mZm//////////////7+/v7//////v7+/v///////////v7+/v///////////v7+/v///////////v7+/v//////////KCj//wAA/v4AAP//PT3///7+/v7///////////7+/v7///////////7+/v7///////////7+/v7//////v7+/v///////////v7+/v///////////v7+/v//////////Pz/+/gAA//8AAP//AAD+/gAA//8AAP//AAD+/mZm//////////////7+/v7//////v7+/v///////////v7+/v///////////v7+/v///////////v7+/v//////////KCj//wAA/v4AAP//PT3///7+/v7///////////7+/v7///////////7+/v7///////////7+/v7//////v7+/v///////////v7+/v///////////v7+/v//////////Ozv+/gAA//8AAP//AAD+/gAA/v4AAP7+AAD+/hAQ/v4oKP7+KCj+/igo/v4oKP7+KCj+/igo/v4oKP7+KCj+/igo/v4oKP7+KCj+/igo/v4oKP7+KCj+/igo/v4oKP7+Bgb+/gAA/v4AAP7+CQn+/igo/v4oKP7+KCj+/igo/v4oKP7+KCj+/igo/v4oKP7+KCj+/igo/v4oKP7+KCj+/igo/v4oKP7+KCj+/igo/v4oKP7+KCj+/igo/v4oKP7+CAj+/gAA/v4AAP7+AAD+/gAA//8AAP//AAD+/gAA//8AAP//AAD//wAA/v4AAP//AAD+/gAA//8AAP//AAD+/gAA//8AAP//AAD+/gAA//8AAP//AAD+/gAA//8AAP//AAD//wAA/v4AAP//AAD//wAA/v4AAP//AAD//wAA/v4AAP//AAD//wAA/v4AAP//AAD//wAA/v4AAP//AAD+/gAA//8AAP//AAD+/gAA//8AAP//AAD+/gAA//8AAP//AAD+/gAA//8AAP//AAD+/gAA//8AAP//AAD+/gAA//8AAP//AAD//wAA/v4AAP//AAD+/gAA//8AAP//AAD+/gAA//8AAP//AAD+/gAA//8AAP//AAD+/gAA//8AAP//AAD//wAA/v4AAP//AAD//wAA/v4AAP//AAD//wAA/v4AAP//AAD//wAA/v4AAP//AAD//wAA/v4AAP//AAD+/gAA//8AAP//AAD+/gAA//8AAP//AAD+/gAA//8AAP//AAD+/gAA//8AAP//AAD+/gAA/v4AAP7+AAD+/gAA/v4AAP7+AAD+/gAA/v4AAP7+AAD+/gAA/v4AAP7+AAD+/gAA/v4AAP7+AAD+/gAA/v4AAP7+AAD+/gAA/v4AAP7+AAD+/gAA/v4AAP7+AAD+/gAA/v4AAP7+AAD+/gAA/v4AAP7+AAD+/gAA/v4AAP7+AAD+/gAA/v4AAP7+AAD+/gAA/v4AAP7+AAD+/gAA/v4AAP7+AAD+/gAA/v4AAP7+AAD+/gAA/v4AAP7+AAD+/gAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA==";
var idata_ico = "data:image/png;base64,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";
var fish_ico="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAADAAAAAwCAQAAAD9CzEMAAAABGdBTUEAALGPC/xhBQAAACBjSFJNAAB6JgAAgIQAAPoAAACA6AAAdTAAAOpgAAA6mAAAF3CculE8AAAAAmJLR0QA/4ePzL8AAAAHdElNRQfeBgkLODFcvD71AAACn0lEQVRYw+2WT0iTcRjHP5vzX7Upmlos1kEwD9FIhh46hFZoUkGXBMMOCQkh2CGKjkoEdoroFEiUHiRYeeggBUsMlaLZH5IQtITpCMxmk2azzbfDfN/9Xufe7fUd1GHP7/Y8/D7f5/fneX4/yFrW/nszpYibacdFdMuZAdx4jafQRhgpyfDTRYFRgRxuJxWQWOMuO41K2PmoIRGhG4tRiRsaAhJBThoVqGdVU8JNbvIdTscqadXcBjsOLCyyulWwgv2UpRDo1cw/NsK8oQt74uQHzPOBO9QkgZdwlUAaAhIS60zRQaEacI6fSEgs0E3RJriZ03iIpomXL+4gVSLEQp8SHGCPECnn5oa43vEWlyhxVMA8wrrhdTGyLXhsTFEXFyjgqRKI0ksOJlqY1YmcY5gR4bQmORCXaCOiBJZpppOgTvwQ1eSQzwmh6t3YZIEq/KoW9ksn3ss+LBynBjijzI7SJQuU8t7AfkvcAi4RYpZqbHgV/zROMwAhAmlVdDILA0UUsot8Iqwp/ip5DTsYNbSCUYqx0koTUM+yEJmOCexl2pBAhHuUA3B4U6pPYgI1LAnOMT7plljHy3368am8M3LBXRGcIZpwMm5oRTKpLYa34hHcw1gBBw/5Ywj/m2tyi28U7r2PI8gHf51v28av0ENeDJRHv+JepEV1/ep4tq11fOV8/IG6yMqGe4LGhH+SjQuM6WrYAfo4JCKeM88XXtBJRZIyKqWDcSUNrcvqY4AG9eNqwoGZKEuENGu1GCenaKAy4VGCCEF8vMPDBHNEjLSEEmq5zJwq7++042R3yk9o2pbLS5XAoPFvl9psvBbwnzmYWTzU8kPB+2nONB56BPzZzOPLlEY4ybF0Jug9oChDvAJ8PGYm8/lnLWv/xP4C54UGs0hQL5AAAAAldEVYdGRhdGU6Y3JlYXRlADIwMTctMTEtMTJUMTA6NTM6MTcrMDg6MDBm9dR5AAAAJXRFWHRkYXRlOm1vZGlmeQAyMDE0LTA2LTA5VDExOjU2OjQ5KzA4OjAw/5T2jgAAAE10RVh0c29mdHdhcmUASW1hZ2VNYWdpY2sgNy4wLjEtNiBRMTYgeDg2XzY0IDIwMTYtMDktMTcgaHR0cDovL3d3dy5pbWFnZW1hZ2ljay5vcmfd2aVOAAAAGHRFWHRUaHVtYjo6RG9jdW1lbnQ6OlBhZ2VzADGn/7svAAAAGHRFWHRUaHVtYjo6SW1hZ2U6OkhlaWdodAA1MTKPjVOBAAAAF3RFWHRUaHVtYjo6SW1hZ2U6OldpZHRoADUxMhx8A9wAAAAZdEVYdFRodW1iOjpNaW1ldHlwZQBpbWFnZS9wbmc/slZOAAAAF3RFWHRUaHVtYjo6TVRpbWUAMTQwMjI4NjIwOZntnxAAAAASdEVYdFRodW1iOjpTaXplADcuMzNLQhmSqU0AAABfdEVYdFRodW1iOjpVUkkAZmlsZTovLy9ob21lL3d3d3Jvb3Qvc2l0ZS93d3cuZWFzeWljb24ubmV0L2Nkbi1pbWcuZWFzeWljb24uY24vc3JjLzExNjkwLzExNjkwODQucG5nM8JenwAAAABJRU5ErkJggg==";

var pdf_ico = "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAYAAABzenr0AAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAAJcEhZcwAADsMAAA7DAcdvqGQAAAUhSURBVFhHtZdZiBxVFIZ7eq2u6VnijDOZsWcLyGDAJUgEFxTR4IsLOmrENRF8cceAGygoiBBFQY1roiQiIUFRcHkYNFEEHUENKCERXGIIbomGyYPOYvfx+2/X7VSPzmIsC3666tatc/77n+XeTs12VUd6AxsID9pgs9nAkeHe1ux2TBVrFue+RsAGsD6G1y4JM3Ztc9auAhcUMw4Xg2t4vg7o/YU8C5dzrzHhjpacVfub3TzsjJVSqTZ+57w2Ak22bFPKVgQZu6GUtVMLaTcmnM3YyjBrJ+UPjw1n07ZCBHDen2mqj6dBpS+0VTUC1rQAEuuAm7wo3WQTfDzaVbBdvUV7pD3vVipJt3YWbO8xRXvr6IJlmfvZ4oDn0N7pCpxS3kYnNuIEhPlINBAYL4fWze9qDOyFhGTdw6/ed7NSkZHs23G8dlHejRVQztvwBKIQ1DEXiTqBdj7+mVV+0aPVFd0qRlBgH/d+zk/c39qStVdR5ACOdkNOueHfi4Axfv0MAhHGQCdouBoUOIQCa0ikoWwtrjL0Y0TgIhxJgeNzaRvrDuyh9pyFrF4h8TZEYLxcdKo9f1TenothQ0fBtnTktjCv4WogcAACy/OHV7QSBSbJ6k+J+Z5o9Rr/nOd7WnP1eR4i8AvzKGNHtgFDJSqk+D7zGq4XgftYGdzPynOxmAqKs1fEI5gxx0Nq7BeB/tAmCUUcIjFRDkaZ13AtA6tjWLU0k74bySovINvT4DGS7XHwFJCUkvYJ7tcB3cexGZn/iJwJSsj5CPztqp4YdlYHwoo3Mi/iHTO6H6VK3qBkHZlIDY0viMBET+5Y+kHlzxj72aC+odKVEzmQMsJWnKuhLaN5qaIq0ftECei9HJ9Pdagy7m/L2ZOEoZVEbAO9UYf01ZMogSkgg3KoXLmTijgOEkpYOVdCY8ohT8LuoywVnsQIyPmbyMx020jiqcSkhsLxA5KreamVn0wIShD4hL6RGAFl9iFQjiT+RqvDuVRxsQaao/1DlXNmIWPfJ6mAVv8uGxZTHTZ15J3x+PuXUUXSG03Mk0ssB2ToYyRlqoP2kB10Rk9C7+8iJ5SMslGNfZcIgWlQYWXaqJju0EU4tlH7IiFHb0f58W0UHn2XGAFBsVaTuTK267Hluq4pR8JSquJq3seVSYyAoJXJqJJNfYBPHXR6GuedNi896+zgSSVKQFA4nGF+n6Ef+E1rkJDsRP73cD7I2K/qlklVwT9BZSci6gNrqX8lIKbsdXLhJYjdTFu2of+RgMqsGoVEjvZD5EacYs7lxaOQ+hpFqIjkCGjVfo7yQQeR3T1F+0hdLyKiRoRJd3jRISYRAlqt3imu+lVsN9F4dJA9hyM8JuwySnRKivDuDI74OuR8hwKQ/m8EXEfD6Aes8iwMD5P9O1i1zpEncK+tdyBKRP1JsSUle5izo543Uy3VwSMgIKceaq33se0qyZ4luU5hs1En1ElIfUCnZXXJZlbckk7ZNCpIGcy6+f+KgFqoq/V6cpXcnxam2C0cTqcZ28Xq9XwaajwIMd2fRxiEc8GlhELENL6TuZy0FkaA1VZ+I8brYa1udzoObkPSJcgrZyLkTzk6G/KZXUEDeiAiMRP6/6iknFpQGS7ODavBSH5l9pcw138A/QPqQO6vXH+vtVcXFkh8iOw3oYr2fa10DVmvHFlOiG5nXNu3cuf3crAtcjP7Ve0LeibLwUHVtet00Ur1p0XQs09KDxciqRKbHw+f7xETfcErNS+p1F9b1z/MoMKQ6AAAAABJRU5ErkJggg==";
var epub_ico = "data:image/png;base64,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";

// var doi_ref='/\b(10[.][0-9]{4,}(?:[.][0-9]+)*\/(?:(?!["&\'<>])\S)+)\b/i';

// code from https://github.com/mdmower/doi-resolver-chrome/blob/master/autolink.js
// https://stackoverflow.com/questions/27910/finding-a-doi-in-a-document-or-page

var link, sciHubLink, sciHubLinkIMG;
var orig_link;

var cnki_dbcode, cnki_filename;
var paper_id, paper_type;

// replace text in an HTML page without affecting the tags
// https://stackoverflow.com/questions/1444409/in-javascript-how-can-i-replace-text-in-an-html-page-without-affecting-the-tags
var definitions = {
    findDoi: /\b(10[.][0-9]{4,}(?:[.][0-9]+)*\/(?:(?!["&\'<>])\S)+)\b/ig,
    findUrl: /^(?:https?\:\/\/)(?:dx\.)?doi\.org\/(10[.][0-9]{4,}(?:[.][0-9]+)*\/(?:(?!["&\'<>])\S)+)$/ig,
    doiResolver: "https://doi.org/"
};

function replaceInElement(element, find, replace) {
    // iterate over child nodes in reverse, as replacement may increase length of child node list.

    // don't touch these elements
    var forbiddenTags = ["A", "BUTTON", "INPUT", "SCRIPT", "SELECT", "STYLE", "TEXTAREA"];
    for (var i = element.childNodes.length - 1; i >= 0; i--) {
        var child = element.childNodes[i];
        if (child.nodeType === Node.ELEMENT_NODE) {
            if (forbiddenTags.indexOf(child.nodeName) < 0) {
                replaceInElement(child, find, replace);
            } else if (child.nodeName === "A") {
                if (definitions.findUrl.test(child.href)) {
                    child.href = child.href.replace(definitions.findUrl, definitions.doiResolver + "$1");
                }
            }
        } else if (child.nodeType === Node.TEXT_NODE) {
            replaceInText(child, find, replace);
        }
    }
}
function replaceInText(text, find, replace) {
    var match;
    var matches = [];
    while (match = find.exec(text.data)) {
        matches.push(match);
    }
    for (var i = matches.length; i-- > 0; ) {
        match = matches[i];
        text.splitText(match.index);
        text.nextSibling.splitText(match[0].length);
        text.parentNode.replaceChild(replace(match), text.nextSibling);
    }
}

var makeLinkClickable = function () {
    if (/^https?:\/\/xueshu\.baidu\.com\/u\/paperhelp/i.test(site)) {

        // 	  	  var exp2 =/(^|[^\/])(www\.[\S]+(\b|$))/gim;
        var plain_link = document.getElementsByTagName("span");
        for (var i = plain_link.length; i-- > 0; ) {
            plain_link[i].innerHTML = plain_link[i].innerHTML.replace(/(\b(https?|ftp|file):\/\/[-A-Z0-9+&@#\/%?=~_|!:,.;]*[-A-Z0-9+&@#\/%=~_|])/gim, "<a href='$1'>$1</a>");
            plain_link[i].innerHTML = plain_link[i].innerHTML.replace(/(^|[^\/])(www\.[\S]+(\b|$))/gim, '$1<a href="http://$2" target="_blank">$2</a>');
        }
    }
};

// https://stackoverflow.com/questions/1444409/in-javascript-how-can-i-replace-text-in-an-html-page-without-affecting-the-tags
function replaceDOIsWithLinks() {
    try {
        replaceInElement(document.body, definitions.findDoi, function (match) {
            var link = document.createElement('a');
            link.href = "https://doi.org/" + match[0];
            link.appendChild(document.createTextNode(match[0]));
            return link;
        });
    } catch (ex) {
        console.log("DOI autolink encountered an exception", ex);
    }
}

// https://stackoverflow.com/questions/23683439/gm-addstyle-equivalent-in-tampermonkey
function addGlobalStyle(css) {
    var head, style;
    head = document.getElementsByTagName('head')[0];
    if (!head) { return; }
    style = document.createElement('style');
    style.type = 'text/css';
    style.innerHTML = css;
    head.appendChild(style);
}

function translateSciHub() {
    if (/^https?:\/\/(\w+\.)?sci-hub\./i.test(site)) {
        if (document.title.trim() == "Ошибка: не удалось открыть страницу") {
            document.body.innerHTML = document.body.innerHTML.replace('! Ошибка: не удалось открыть страницу', '! Ошибка: не удалось открыть страницу<br />Error: could not open page.<br />错误：无法打开页面。');
            document.body.innerHTML = document.body.innerHTML.replace(/попробовать еще раз( \/ Try again)/, "попробовать еще раз / Try again / 重试");
            document.body.innerHTML = document.body.innerHTML.replace(/попробовать еще раз ➝/, "попробовать еще раз / Try again / 重试 ➝");
        } else if (document.title.trim() == "Для просмотра статьи разгадайте капчу") {
            document.body.innerHTML = document.body.innerHTML.replace("для просмотра статьи разгадайте капчу", "для просмотра статьи разгадайте капчу / Enter the captcha to view the article. / 输入验证码以便查看文章");
            document.body.innerHTML = document.body.innerHTML.replace("для скачивания статьи разгадайте капчу", "для скачивания статьи разгадайте капчу / Enter the captcha to download the article. / 输入验证码以便下载文章");
            document.body.innerHTML = document.body.innerHTML.replace("Капча введена неправильно, попробуйте еще раз", "Капча введена неправильно, попробуйте еще раз / Captcha entered incorrectly, try again / 验证码有误，请重新输入");
            document.body.innerHTML = document.body.innerHTML.replace("[ показать другую картинку ]", "[ показать другую картинку / Show another picture / 更换图片 ]");
            document.body.innerHTML = document.body.innerHTML.replace("Продолжить", "Продолжить / Continue / 继续");
        } else if (document.title.trim() == "Перекачка статьи" || document.title.trim() == "Загрузка статьи") {
            document.body.innerHTML = document.body.innerHTML.replace("Страничка проекта Sci-Hub в социальных сетях", "Страничка проекта Sci-Hub в социальных сетях / Sci-Hub project page in SNS / Sci-Hub 社交网站页面");
        } else if (document.title.trim() == "Загрузка статьи") {
            document.body.innerHTML = document.body.innerHTML.replace("повторное скачивание статьи", "повторное скачивание статьи / Reloading the article / 正在重新加载文章");
        } else {
            document.body.innerHTML = document.body.innerHTML.replace("⇣ save", "⇣ save / 保存");
            document.body.innerHTML = document.body.innerHTML.replace("↻ reload", "↻ reload / 重载");
            document.body.innerHTML = document.body.innerHTML.replace("↩ Sci-Hub", "↩ Sci-Hub / 首页");
            document.body.innerHTML = document.body.innerHTML.replace("🐦 twitter", "🐦 twitter / 推特");
            document.body.innerHTML = document.body.innerHTML.replace("support →", "support / 捐助 →");
            document.body.innerHTML = document.body.innerHTML.replace("статья не найдена / article not found", "статья не найдена / article not found / 文章不存在");
            document.body.innerHTML = document.body.innerHTML.replace("<h2>•• поиск прокси для скачивания статьи ••</h2>", "•• поиск прокси для скачивания статьи / search proxy for downloading articles / 正在查找代理并下载文章 ••");
            document.body.innerHTML = document.body.innerHTML.replace("<div id=\"noproxy\" style=\"display: block;\">подходящих прокси не найдено</div>", "подходящих прокси не найдено / no suitable proxies found /没有找到合适的代理");
            document.body.innerHTML = document.body.innerHTML.replace("✏ SCI-HUB в социальной сети ВКонтакте", "✏ SCI-HUB в социальной сети ВКонтакте<br />✏ SCI-HUB on vk.com<br />✏SCI-HUB的vk.com");
            document.body.innerHTML = document.body.innerHTML.replace("новости проекта и обсуждения", "новости проекта и обсуждения<br />Project news and discussions<br />项目动态及讨论");

            document.body.innerHTML = document.body.innerHTML.replace("ожидайте...", "ожидайте... <br /> Waiting... <br /> 稍候……");
            document.body.innerHTML = document.body.innerHTML.replace("идет загрузка статьи...", "идет загрузка статьи... <br /> Downloading the article... <br /> 正在下载文章……");
        }
    }

}

var floatBox = function () {
    // 判断是否为英文文献
    if (!site.startsWith(sciHubBaseUrl)) {
        var sciHubUrl = getSciHubLink(site);
        var unpaywallUrl = getUnpaywallLink(site);

        if (sciHubUrl.trim().length > 0) {
            addFloatBox(sciHubUrl, sci_hub_ico);
        }
        else if (/https?:\/\/xueshu\.baidu\.com\/usercenter\/paper/i.test(site) ) {
            article_title= document.title.toString().split("_")[0];
        }
        else if (/xuewen\.cnki\.net\/(\w{4})-(\w+)\.html/i.test(site) || /^https?:\/\/(\w+\.)?(en\.)?cnki\.com\.cn\/Article(_en)?\/\w{4}(Total|(-?\d+))[^#]+$/i.test(site)) {
            article_title= document.title.toString().split("--")[0];
            addFloatBox(getCnkiLink(site), cnki_ico);
            // addScihubIco(getIdataLink(site), link[i], idata_ico);
        }
        else if (/cnki\.net\/KCMS\/detail\/detail\.aspx/i.test(site) ) {
            article_title= document.title.toString().split("--")[0];
            addFloatBox(getIdataLink(site), idata_ico);
        }
        else if (/\.cqvip\.com\/QK\//i.test(site) && vipMirrorBaseUrl.trim().length > 0) {
            addFloatBox(getVipLink(site), vip_ico);
        }
        else if (/\.cqvip\.com\/Main\/Detail\.aspx/i.test(site) && vipMirrorBaseUrl.trim().length > 0) {
            addFloatBox(getVipLink(site), vip_ico);
        }
        else if (/\.wanfangdata\.com\.cn\//i.test(site) && wanfangMirrorBaseUrl.trim().length > 0) {
            addFloatBox(getWanfangLink(site), wanfang_ico);
        }

        if (unpaywallUrl.trim().length > 0) {
            addFloatBox(unpaywallUrl, unpaywall_ico);
        }
    }
};

var modifyLink = function () {

    'use strict';

    var sciHubUrl = "";

    var link_type;

    if (document.title.trim().includes(" - Google 学术搜索") || document.title.trim().includes(" - Google Scholar") || site.includes("://scholar.google.")) {
        // Google Scholar
        link = document.getElementsByClassName('gs_rt');
        for (var i = link.length; i-- > 0; ) {
            try {
                orig_link = link[i].getElementsByTagName("a")[0].href;

                var creatingElement;
                if ((orig_link !== undefined) &&
                    (orig_link.search("patents.google") == -1) &&
                    (orig_link.search("books.google") == -1) &&
                    (orig_link.search("scholar.google.com/citations") == -1)&&
                    (orig_link.search("cqvip.com") == -1)&&
                    (orig_link.search("cnki.net") == -1)&&
                    (orig_link.search("cnki.com.cn") == -1)&&
                    (orig_link.search("wanfangdata.com.cn") == -1)&&
                    (orig_link.search("biorxiv.org") == -1)&&
                    (orig_link.search("arxiv.org") == -1)&&
                    (orig_link.search("researchgate.net") == -1)) {
                    link[i].getElementsByTagName("a")[0].className = "sci_article";
                }
            } catch (e) {}
        }
    }

    // not Google Scholar
    // add button after link

    link = document.getElementsByTagName("a");

    for (i = link.length; i-- > 0; ) {

        // 将百度学术网址还原成文献的原始网址
        // Modify the document url to original version in Baidu xueshu
        if (/^https?:\/\/xueshu\.baidu\.com\/s\?wd=paperuri.+sc_vurl=([^&]+)/i.test(link[i].href)) {
            // check if it is a baidu xueshu link
            // sample url: http://xueshu.baidu.com/s?wd=paperuri%3A%28de8bb54ffad7ed75376b6c2ac97e2d77%29&filter=sc_long_sign&tn=SE_xueshusource_2kduw22v&sc_vurl=http%3A%2F%2Fwww.sciencedirect.com%2Fscience%2Farticle%2Fpii%2FS088240101830545X&ie=utf-8&sc_us=11967506776210348226
            // sample url: http://xueshu.baidu.com/s?wd=paperuri%3A%286536e35bc722fc55f33372dd2b30beb4%29&filter=sc_long_sign&tn=SE_xueshusource_2kduw22v&sc_vurl=http%3A%2F%2Feuropepmc.org%2Fabstract%2FMED%2F27028052&ie=utf-8&sc_us=16239811212598786534

            link[i].href = decodeURIComponent(/sc_vurl=([^&]+)/i.exec(link[i].href)[1]);
        }

        orig_link = link[i].href;
        if (site != orig_link && !orig_link.startsWith(sciHubBaseUrl)) {
            // standardize the plos url
            try {
                orig_link = decodeURIComponent(orig_link).replace("://www.plosone.org/article/info:doi/", "://journals.plos.org/plosone/article?id=");
            } catch (e) {}

            sciHubUrl = getSciHubLink(orig_link);
            if (sciHubUrl.trim().length > 0) {
                addScihubIco(sciHubUrl, link[i], sci_hub_ico);
            }
            else if (link[i].className == "sci_article") {
                addScihubIco(sciHubBaseUrl + orig_link, link[i], sci_hub_ico);
            }

            var unpaywallUrl = getUnpaywallLink(orig_link);
            if (unpaywallUrl.trim().length > 0) {
                addScihubIco(unpaywallUrl, link[i], unpaywall_ico);
            }

            // if original link if a direct pdf download link
            // 检查原始链接是否可以直接下载
            if (/^https?:\/\/[\w\.]+\/doi\/pdf\/10\./i.test(orig_link) ||
                //https://arc.aiaa.org/doi/pdf/10.2514/1.A33621

                /^https?:\/\/[\w\.]+\/doi\/pdfplus\/10\./i.test(orig_link) ||
                //https://arc.aiaa.org/doi/pdfplus/10.2514/1.A33621

                /^https?:\/\/(\w+\.)?biomedcentral\.com\/(track|content)\/pdf\/[^#]+$/i.test(orig_link) ||
                /^https?:\/\/(\w+\.)?bmj\.com\/(track|content)\/[^#]+\.full\.pdf$/i.test(orig_link) ||
                // /^https?:\/\/(\w+\.)?springer\.com\/content\/pdf\/10\.1007[\%\w\d-]+\.pdf$/i.test(orig_link) ||
                // https://link.springer.com/content/pdf/10.1007%2Fs13238-018-0537-4.pdf

                /^https?:\/\/(\w+\.)?cnki\.net\/[^#]+\.pdf$/i.test(orig_link) ||
                //http://pmmp.cnki.net/Resources/CDDPdf/evd/base/%E4%B8%AD%E5%9B%BD%E5%AE%9E%E7%94%A8%E5%A6%87%E7%A7%91%E4%B8%8E%E4%BA%A7%E7%A7%91%E6%9D%82%E5%BF%97/%E7%97%85%E4%BE%8B%E5%88%86%E6%9E%90/%E5%AD%90%E5%AE%AB%E9%A2%88%E7%94%B5%E7%8E%AF%E5%88%87%E9%99%A4%E6%9C%AF%E5%AF%B9203%E4%BE%8B%E5%AE%AB%E9%A2%88%E4%B8%8A%E7%9A%AE%E5%86%85%E7%98%A4%E5%8F%98%E7%9A%84%E7%96%97%E6%95%88%E7%A0%94%E7%A9%B6[1].pdf

                /^https?:\/\/patentimages\.storage\.googleapis\.com\/[^#]+\.pdf$/i.test(orig_link) ||
                // https://patentimages.storage.googleapis.com/b4/f8/02/9cedfdf1461521/CN204653342U.pdf

                /^https?:\/\/\w+\.asm\.org\/content\/[^#]+\.full-text\.pdf$/i.test(orig_link) ||
                // https://msystems.asm.org/content/msys/4/3/e00107-19.full-text.pdf

                /^https?:\/\/media\.nature\.com\/original\/[^#]+\.pdf$/i.test(orig_link)
                // https://media.nature.com/original/magazine-assets/d41586-020-00203-4/d41586-020-00203-4.pdf
               ) {
                addScihubIco(orig_link, link[i], pdf_ico);
            }

            else if (/^https?:\/\/(dx\.)?doi\.org\/10/i.test(orig_link)) {
                var doi=paper_id = /.org\/([^&#]+)/i.exec(orig_link)[1];

                if (/^https?:\/\/(dx\.)?doi\.org\/10\.1371/i.test(orig_link)) {
                    // original https://doi.org/10.1371/journal.pone.0131667
                    // pdf url: http://journals.plos.org/plosone/article/file?id=10.1371/journal.pone.0131667&type=printable

                    addScihubIco("http://journals.plos.org/plosone/article/file?id=" + doi + "&type=printable", link[i], pdf_ico);
                } else if (/^https?:\/\/(dx\.)?doi\.org\/10\.1186/i.test(orig_link)) {

                    addScihubIco("https://www.biomedcentral.com/track/epub/" + doi + ".epub", link[i], epub_ico);
                    addScihubIco("https://www.biomedcentral.com/track/pdf/" + doi + ".pdf", link[i], pdf_ico);
                } else if(/^https?:\/\/(dx\.)?doi\.org\/10\.3389/i.test(orig_link)){
                    // https://doi.org/10.3389/fmicb.2018.01631

                    addScihubIco("https://www.frontiersin.org/articles/" + doi + "/epub", link[i], epub_ico);
                    addScihubIco("https://www.frontiersin.org/articles/" + doi + "/pdf", link[i], pdf_ico);
                } else if(/^https?:\/\/(dx\.)?doi\.org\/10\.1038\/s/i.test(orig_link)){
                    // https://doi.org/10.1038/srep09938
                    // https://www.nature.com/articles/srep09938.pdf

                    addScihubIco("https://www.nature.com/articles/" + doi.replace("10.1038/","").replace(".pdf","") + ".pdf", link[i], pdf_ico);
                }

            }
            // Provide direct link for open access journal
            // 开放获取期刊提供直接下载链接
            else if (/^https?:\/\/(\w+\.)?biomedcentral\.com\/\d+-\d+\/\d+\/\d+(\/abstract)?(\?fmt_view=\w+)?$/i.test(orig_link)) {
                // original url: http://www.biomedcentral.com/1471-2164/9/312
                // pdf url: https://bmcgenomics.biomedcentral.com/track/pdf/10.1186/1471-2164-9-312
                // epub url: https://bmcgenomics.biomedcentral.com/track/epub/10.1186/1471-2164-9-312

                paper_id = /com\/([\/-\d+]+\d)/i.exec(orig_link)[1];
                paper_id = paper_id.replace(/\//g, "-");

                addScihubIco("https://www.biomedcentral.com/track/epub/10.1186/" + paper_id + ".epub", link[i], epub_ico);

                addScihubIco("https://www.biomedcentral.com/track/pdf/10.1186/" + paper_id + ".pdf", link[i], pdf_ico);
            }
            else if (/^https?:\/\/(\w+\.)?biomedcentral\.com\/articles\/[^#]+$/i.test(orig_link)) {
                // original url: https://ehjournal.biomedcentral.com/articles/10.1186/s12940-018-0403-0
                // pdf url: https://ehjournal.biomedcentral.com/track/pdf/10.1186/s12940-018-0403-0
                // epub url: https://ehjournal.biomedcentral.com/track/epub/10.1186/s12940-018-0403-0

                paper_id = /articles\/([^&]+)$/i.exec(orig_link)[1];

                addScihubIco("https://www.biomedcentral.com/track/epub/" + paper_id + ".epub", link[i], epub_ico);

                addScihubIco("https://www.biomedcentral.com/track/pdf/" + paper_id + ".pdf", link[i], pdf_ico);
            }
            else if (/^https?:\/\/(\w+\.)?plos\.org\/\w+\/article\?id=[^#]+$/i.test(orig_link)) {
                // original url: http://journals.plos.org/plosone/article?id=10.1371/journal.pone.0131667
                // pdf url: http://journals.plos.org/plosone/article/file?id=10.1371/journal.pone.0131667&type=printable
                // original url: http://journals.plos.org/plosbiology/article?id=10.1371/journal.pbio.2005206
                // pdf url: http://journals.plos.org/plosone/article/file?id=10.1371/journal.pone.0199542&type=printable
                // original url: http://www.plosone.org/article/info%3Adoi%2F10.1371%2Fjournal.pone.0061505
                // original url 2: http://journals.plos.org/plosone/article?id=10.1371/journal.pone.0061505
                // pdf url: http://journals.plos.org/plosone/article/file?id=10.1371/journal.pone.0061505&type=printable

                paper_id = /article\?id=([^&]+)/i.exec(orig_link)[1];
                addScihubIco(orig_link.replace("article?id=", "article/file?id=") + "&type=printable", link[i], pdf_ico);
            }
            else if (/\.plosjournals\.org\/plosonline\/\?request=get-document&doi=/i.test(orig_link)) {
                // original url: http://biology.plosjournals.org/plosonline/?request=get-document&doi=10.1371/journal.pbio.0000005

                paper_id = /doi=([^&]+)/i.exec(orig_link)[1];
                addScihubIco("http://journals.plos.org/plosone/article/file?id=" + paper_id + "&type=printable", link[i], pdf_ico);
            }
            else if (/^https?:\/\/(\w+\.)?frontiersin\.org\/articles\/[^#]*?(\/)?(full|pdf|epub|abstract)?$/i.test(orig_link)) {
                // original url: https://www.frontiersin.org/articles/10.3389/fmicb.2016.02108/full
                // original url: https://www.frontiersin.org/articles/10.3389/fmicb.2016.02108/pdf

                // https://www.frontiersin.org/articles/10.3389/fmicb.2012.00410
                // pdf url: https://www.frontiersin.org/articles/10.3389/fmicb.2016.02108/pdf
                // epub url: https://www.frontiersin.org/articles/10.3389/fmicb.2016.02108/epub

                paper_id = /articles\/([^#]*?)(\/)?(full|pdf|epub|abstract)?$/i.exec(orig_link)[1];
                addScihubIco("https://www.frontiersin.org/articles/" + paper_id + "/pdf", link[i], pdf_ico);

                addScihubIco("https://www.frontiersin.org/articles/" + paper_id + "/epub", link[i], epub_ico);
            }
            else if (/^https?:\/\/(www\.)?aasv\.org\/shap\/issues\/(v\d\d?n\d)\/\2p\d+\.html/i.test(orig_link)) {
                // AASV
                // https://www.aasv.org/shap/issues/v14n6/v14n6p296.html
                // https://www.aasv.org/shap/issues/v14n6/v14n6p296.pdf

                // https://www.aasv.org/shap/issues/v25n6/v25n6jshap.pdf

                addScihubIco(orig_link.replace(".html", ".pdf"), link[i], pdf_ico);

            }

            else if (/^https?:\/\/(www\.)?mdpi\.com\/\d+-\d+\/\d+\/\d+\/\d+\/htm$/i.test(orig_link)) {
                // https://www.mdpi.com/2076-2615/10/3/380/htm
                // https://www.mdpi.com/2076-2615/10/3/380/pdf

                addScihubIco(orig_link.replace("/htm", "/pdf"), link[i], pdf_ico);

            }
            else if (/^https?:\/\/(www\.)?nature\.com\/articles\/srep\d+(\.pdf)?(\?origin=\w+)?$/i.test(orig_link)||
                     /^https?:\/\/(www\.)?nature\.com\/articles\/s41586-\d+-\d+-\w$/i.test(orig_link)||
                     /^https?:\/\/(www\.)?nature\.com\/articles\/s41598-\d+-\d+-\w$/i.test(orig_link)||
                     /^https?:\/\/(www\.)?nature\.com\/articles\/d41586-\d+-\d+-\w$/i.test(orig_link)||
                     /^https?:\/\/(www\.)?nature\.com\/articles\/s41591-\d+-\d+-\w$/i.test(orig_link)) {
                // Scientific Reports
                // https://www.nature.com/articles/srep09938
                // https://doi.org/10.1038/srep09938
                // https://www.nature.com/articles/srep09938.pdf
                // https://www.nature.com/articles/s41591-019-0450-2
                // https://www.nature.com/articles/s41598-018-31664-3
                // https://www.nature.com/articles/d41586-019-01591-y
                // https://www.nature.com/articles/s41586-019-1236-x
                //                 https://www.nature.com/articles/s41598-019-45066-6

                addScihubIco(orig_link.replace(".pdf","")+".pdf", link[i], pdf_ico);

            }
            else if (/^https?:\/\/(www\.)?biorxiv\.org\/content\/.*(\d|(\.(abstract|pdf)))+$/i.test(orig_link)) {
                // biorxiv
                // https://www.biorxiv.org/content/early/2018/04/04/294678
                // https://www.biorxiv.org/content/early/2018/04/04/294678.abstract
                // https://www.biorxiv.org/content/early/2018/04/04/294678.full.pdf
                // https://www.biorxiv.org/content/biorxiv/early/2019/01/23/528737.full-text.pdf

                addScihubIco(orig_link.replace(/(\.[\w-]+)+$/i,"")+".full.pdf", link[i], pdf_ico);

            }

            else if (/^https?:\/\/(www\.)?arxiv\.org\/(abs|pdf)\/([\w-]+\/)?[\d\.]+(\.pdf.*)?$/i.test(orig_link)) {
                // arxiv
                // https://arxiv.org/abs/hep-th/9802150
                // https://arxiv.org/pdf/hep-th/9802150
                // https://arxiv.org/abs/1409.1556
                // https://arxiv.org/pdf/1409.1556

                // https://arxiv.org/pdf/1404.1100.pdf?utm_content=bufferb37df&utm_medium=social&utm_source=facebook.com&utm_campaign=buffer
                // https://arxiv.org/pdf/1511.06434.pdf%C3%AF%C2%BC%E2%80%B0

                addScihubIco(orig_link.replace("/abs/","/pdf/"), link[i], pdf_ico);

            }

            else if(/^https?:\/\/\w+\.asm\.org\/content\/\d+\/\d+\/e\d+-\d+(\?.*)?$/i.test(orig_link)){
                // https://msystems.asm.org/content/4/3/e00107-19
                // https://msystems.asm.org/content/msys/4/3/e00107-19.full-text.pdf

                // https://jcm.asm.org/content/58/5/e00310-20
                // https://jcm.asm.org/content/jcm/58/5/e00310-20.full-text.pdf

                // https://mbio.asm.org/content/11/2/e00516-20?utm_campaign=mBio&utm_id=004v7j4nnf4zxb4&utm_medium=social&utm_source=twitter
                // https://mbio.asm.org/content/mbio/11/2/e00516-20.full-text.pdf

                addScihubIco(orig_link.replace(/^(https?:\/\/(\w{1,4})\w*\.asm\.org\/content\/)(\d+\/\d+\/e\d+-\d+)/i,"$1$2/$3")+".full-text.pdf", link[i], pdf_ico);
            }

            else if (/^https?:\/\/journals\.aps\.org\/\w+\/abstract\/10\.\d+\//i.test(orig_link)) {
                // original url: https://journals.aps.org/prl/abstract/10.1103/PhysRevLett.127.041301
                // pdf url: https://journals.aps.org/prl/pdf/10.1103/PhysRevLett.127.041301

                var paper = /org\/(\w+)\/abstract/i.exec(orig_link)[1];
                paper_id = /10\.\d+\/.*/i.exec(orig_link)[0];

                addScihubIco("https://journals.aps.org/"+paper+"/pdf/" + paper_id , link[i], pdf_ico);
            }


            else if (/\/ch\/reader\/view_abstract\.aspx\?/i.test(orig_link)) {
                // 猪业科学、农业工程学报、农业机械学报
                // http://www.tcsae.org/nygcxb/ch/reader/view_abstract.aspx?file_no=20201721&flag=1
                // http://www.j-csam.org/jcsam/ch/reader/view_abstract.aspx?file_no=20200901&flag=1
                // http://www.csis.cn/ch/reader/view_abstract.aspx?flag=1&file_no=20200301&journal_id=zykx
                addScihubIco(orig_link.replace("view_abstract","create_pdf"), link[i], pdf_ico);
            }

            else if (/xuewen\.cnki\.net\/(\w{4})-(\w+)\.html/i.test(orig_link) ||
                     /^https?:\/\/(\w+\.)?(en\.)?cnki\.com\.cn\/Article(_en)?\/\w{4}(Total|(-?\d+))[^#]+$/i.test(orig_link)) {
                // 用于链接图标
                addScihubIco(getLuooqiLink(link[i].text), link[i], fish_ico);
                addScihubIco(getCnkiLink(orig_link), link[i], cnki_ico);
                addScihubIco(getIdataLink(orig_link), link[i], idata_ico);

                if( isCnkiUser && /^https?:\/\/(\w+\.)?(en\.)?cnki\.com\.cn\/Article(_en)?\/\w{4}(Total|(-?\d+))[^#]+$/i.test(orig_link)){
                    // 如果为知网空间，生成 pdf 下载链接
                    // http://cpfd.cnki.com.cn/Article/CPFDTOTAL-ZGXJ201010003046.htm
                    // http://search.cnki.net/down/default.aspx?filename=ZGXJ201010003046&dbcode=CPFD&year=2010&dflag=pdfdown

                    cnki_dbcode = /(\w{4})(Total|(-?\d+))-([^&]+)\.htm/i.exec(orig_link)[1];
                    cnki_filename = /(Total|(-?\d+))-([^&]+)\.htm/i.exec(orig_link)[3];

                    addScihubIco("http://search.cnki.net/down/default.aspx?filename="+cnki_filename+"&dbcode="+cnki_dbcode+"&dflag=pdfdown", link[i], pdf_ico);
                }

            }else if (/cnki\.net\/KCMS\/detail\/detail\.aspx/i.test(orig_link)) {
                // 用于飘浮图标
                addScihubIco(getLuooqiLink(article_title), link[i], fish_ico);
                var iDataUrl = getIdataLink(orig_link).trim();
                if (iDataUrl.length > 0) {
                    addScihubIco(iDataUrl, link[i], idata_ico);
                }
            }
            else if (/[\.\/]cqvip\.com\/QK\//i.test(orig_link)) {
                addVipDownloadIco(orig_link, link[i]);
                addScihubIco(getLuooqiLink(link[i].text), link[i], fish_ico);
                if(vipMirrorBaseUrl.trim().length > 0){
                    addScihubIco(getVipLink(orig_link), link[i], vip_ico);
                }
            }
            else if (/[\.\/]cqvip\.com\/Main\/Detail(Add)?\.aspx/i.test(orig_link)) {
                addVipDownloadIco(orig_link, link[i]);
                addScihubIco(getLuooqiLink(link[i].text), link[i], fish_ico);
                if(vipMirrorBaseUrl.trim().length > 0){
                    addScihubIco(getVipLink(orig_link), link[i], vip_ico);
                }
            }
            else if (/^https?:\/\/med\.wanfangdata\.com\.cn\/Paper\/Detail\/PeriodicalPaper_\w+\d+$/i.test(orig_link)) {
                // http://med.wanfangdata.com.cn/Paper/Detail/PeriodicalPaper_zhfck202007003

                addScihubIco(getLuooqiLink(link[i].text), link[i], fish_ico);
                if(wanfangMirrorBaseUrl.trim().length > 0){
                    var wanfangUrl = getWanfangLink(orig_link).trim();
                    if (wanfangUrl.length > 0) {
                        addScihubIco(wanfangUrl, link[i], wanfang_ico);
                        // orig: http://d.wanfangdata.com.cn/Patent_CN201410036250.0.aspx
                        // wanfangUrl: http://wanfang.mirror.org.cn/D/Patent.aspx?ID=Patent_CN201410036250.0
                        // pdf: http://patent.wanfangdata.com.cn/PatentFiles.aspx?patentid=CN201410036250.0
                        if (/\/Patent_/i.test(wanfangUrl)){
                            addScihubIco(orig_link.replace(".aspx", "").replace("http://d.g.", "http://d.").replace("http://d.wanfangdata.com.cn/Patent_", "http://patent.wanfangdata.com.cn/PatentFiles.aspx?patentid="), link[i], pdf_ico);
                        }
                        else{
                            addScihubIco(wanfangUrl.replace("D/", "/Service/File/download/"), link[i], pdf_ico);
                        }
                    }
                }
            }
        }
    };
};

var getCnkiLink = function (orig_link) {
    if (/xuewen\.cnki\.net\/(\w{4})-(\w+)\.html/i.test(orig_link)) {
        // CNKI学问
        // http://xuewen.cnki.net/CJFD-GWXM201401018.html

        cnki_dbcode = /(\w{4})-(\w+)\.html/i.exec(orig_link)[1];
        cnki_filename = /(\w{4})-(\w+)\.html/i.exec(orig_link)[2];

        return "http://kns.cnki.net/KCMS/detail/detail.aspx?dbcode=" + cnki_dbcode + "&filename=" + cnki_filename;
    } else if (/^https?:\/\/(\w+\.)?(en\.)?cnki\.com\.cn\/Article(_en)?\/\w{4}(Total|(-?\d+))[^#]+$/i.test(orig_link)) {

        // 知网空间页面跳转到中国知网。如果是英文网页的中文文献，跳转到相应的中文页面。
        // sample url 1 (en):http://www.en.cnki.com.cn/Article_en/CJFDTotal-FKLC201606004.htm
        // sample url 1 (zh):http://kns.cnki.net/KCMS/detail/detail.aspx?dbcode=CJFQ&filename=FKLC201606004

        // sample url 2 (en):http://en.cnki.com.cn/Article_en/CJFDTOTAL-XKXZ201607020.htm
        // sample url 3 (en):http://kns.cnki.net/KCMS/detail/detail.aspx?filename=ahfs201705002&dbname=CJFD&dbcode=CJFQ

        cnki_dbcode = /(\w{4})(Total|(-?\d+))-([^&]+)\.htm/i.exec(orig_link)[1];
        cnki_filename = /(Total|(-?\d+))-([^&]+)\.htm/i.exec(orig_link)[3];

        if (/Article\/([a-z]+)(-\d+)-/i.test(orig_link)) {
            cnki_filename = cnki_filename + ".nh";
        }

        return "http://kns.cnki.net/KCMS/detail/detail.aspx?dbcode=" + cnki_dbcode + "&filename=" + cnki_filename;
    }
    return "";
}

var getIdataLink = function (orig_link) {
    if (/^https?:\/\/(\w+\.)?(en\.)?cnki\.com\.cn\/Article(_en)?\/\w{4}(Total|(-?\d+))[^#]+$/i.test(orig_link)) {
        // 知网空间页面跳转到中国知网。如果是英文网页的中文文献，跳转到相应的中文页面。
        // sample url 1 (en):http://www.en.cnki.com.cn/Article_en/CJFDTotal-FKLC201606004.htm
        // sample url 1 (zh):http://kns.cnki.net/KCMS/detail/detail.aspx?dbcode=CJFQ&filename=FKLC201606004
        // sample url 2 (en):http://en.cnki.com.cn/Article_en/CJFDTOTAL-XKXZ201607020.htm
        // sample url 3 (en):http://kns.cnki.net/KCMS/detail/detail.aspx?filename=ahfs201705002&dbname=CJFD&dbcode=CJFQ

        // http://cpfd.cnki.com.cn/Article/CPFDTOTAL-NSID200709001030.htm

        cnki_dbcode = /(\w{4})(Total|(-?\d+))-([^&]+)\.htm/i.exec(orig_link)[1];
        cnki_filename = /(Total|(-?\d+))-([^&]+)\.htm/i.exec(orig_link)[3];

        if (/Article\/([a-z]+)(-\d+)-/i.test(orig_link)) {
            cnki_filename = cnki_filename + ".nh";
        }

        // 知网中文链接增加iData按钮
        // sample url 1 (zh):http://www.cnki.com.cn/Article/CJFDTotal-NYXJ201706022.htm
        // sample url 2 (zh):http://www.cnki.com.cn/Article/CJFD1996-ZSYX604.007.htm

        //                 cnki_filename=/(Total|(-?\d+))-([^&]+)\.htm/i.exec(orig_link)[3];
        //                 cnki_dbcode=/Article(_en)?\/([a-z]+)(Total|(-?\d+))-/i.exec(orig_link)[1];

        //                 if(/Article(_en)?\/([a-z]+)(-\d+)-/i.test(orig_link)){cnki_filename=cnki_filename+".nh"};

        return "https://www.cn-ki.net/doc_detail?dbcode=" + cnki_dbcode + "&filename=" + cnki_filename;
    } else if (/cnki\.net\/KCMS\/detail\/detail\.aspx/i.test(orig_link)) {
        // 知网中文链接增加iData按钮
        // sample url 1 (cnki):http://kns.cnki.net/KCMS/detail/detail.aspx?dbcode=CJFQ&filename=FKLC201606004
        // sample url 1 (idata):https://www.cn-ki.net/doc_detail?dbcode=CJFQ&filename=FKLC201606004
        // sample url 2 (cnki):http://kns.cnki.net/kcms/detail/detail.aspx?filename=ZGXQ200602002&dbname=cjfd2006&v=
        // sample url 3 (cnki):http://gb.oversea.cnki.net/kcms/detail/detail.aspx?filename=fklc201606004&dbcode=cjfd&dbname=cjfdtemp

        // sample url 2 (zh):http://kns.cnki.net/KCMS/detail/detail.aspx?filename=xmsw201602007&dbname=CJFD&dbcode=CJFQ

        //         cnki_dbcode=/dbcode=([^&]+)/i.exec(site)[1];
        //         cnki_filename=/filename=([^&]+)/i.exec(site)[1];
        return orig_link.toLowerCase().replace(/https?:\/\/(\w+\.)+cnki\.net\/kcms\/detail\/detail\.aspx/, "https://www.cn-ki.net/doc_detail");
    }
    return "";
}

var getLuooqiLink = function (title) {

    title=title.trim();

    if(title=="知网" || title=="维普" || title=="万方"){
        title=article_title;
    }
    return "https://luooqi.com/paper/search?key=" + title;
}

var getVipLink = function (orig_link) {
    // 如果设置了维普镜像地址，增加跳转到镜像按钮

    //     http://www.cqvip.com/QK/90266B/20184/675514160.html
    //     http://vipMirrorBaseUrl/article/detail.aspx?id=675514160

    //     http://www.cqvip.com/Main/DetailAdd.aspx?id=458
    //     http://vip.fjinfo.org.cn:85/article/detail.aspx?id=665074817

    var vip_link;
    if(/\.cqvip\.com\/QK\//i.test(orig_link)){
        vip_link=orig_link.toLowerCase().replace(/http:\/\/\w+.cqvip.com\/qk\/\w+\/\d+\/(\d+)\.html/ig, vipMirrorBaseUrl+"/article/detail.aspx?id=$1");
    }

    //     NO MATCH RULE BELOW
    //     if(/\.cqvip\.com\/Main\/Detail\.aspx/i.test(orig_link)){
    //         vip_link=orig_link.toLowerCase().replace("http://www.cqvip.com/main/detail.aspx?id=", vipMirrorBaseUrl+"/main/")+".html";
    //     }
    return vip_link;
}

var getWanfangLink = function (orig_link) {
    if (/\.wanfangdata\.com\.cn\/Paper\/Detail\?/i.test(orig_link)) {
        // 如果设置了万方镜像地址，增加跳转到镜像按钮
        // sample url (wanfang): http://med.wanfangdata.com.cn/Paper/Detail?id=PeriodicalPaper_zhzxsswk200001015&dbid=WF_QK
        // sample url (mirror): http://wanfang.mirror.org.cn/D/Periodical_zhzxsswk200001015.aspx

        paper_id = /Detail\?id=([^&]+)/i.exec(orig_link)[1].replace("Paper", "");
        return wanfangMirrorBaseUrl + "/D/" + paper_id + ".aspx";
    }
    else if (/d\.(g\.)?wanfangdata\.com\.cn\/(Thesis|Conference|Patent)_[\w\d-\.]+\.aspx/i.test(orig_link)) {
        // 如果设置了万方镜像地址，增加跳转到镜像按钮

        // sample url (wanfang): http://d.wanfangdata.com.cn/Conference_6187192.aspx

        // 不能用 toLowerCase()

        return orig_link.replace("http://d.wanfangdata.com.cn/", wanfangMirrorBaseUrl+"/D/").replace("http://d.g.wanfangdata.com.cn/", wanfangMirrorBaseUrl+"D/");
    }
    else if (/\.wanfangdata\.com\.cn\/(Thesis|Conference|Patent)\//i.test(orig_link)) {
        // 如果设置了万方镜像地址，增加跳转到镜像按钮

        // 期刊论文
        // sample url (wanfang): http://d.wanfangdata.com.cn/Periodical/gdhg201804060
        // sample url (mirror): http://wanfang.mirror.org.cn/D/Periodical_gdhg201804060.aspx

        // 学位论文
        // sample url (wanfang): http://d.wanfangdata.com.cn/Thesis/Y1166736
        // sample url (mirror): http://wanfang.mirror.org.cn/D/Thesis_Y1166736.aspx

        // 会议论文
        // sample url (wanfang): http://d.wanfangdata.com.cn/Conference/6286045
        // sample url (mirror): http://wanfang.mirror.org.cn/D/Conference_6286045.aspx

        paper_id = /(Thesis|Conference|Patent)\/([^&]+)/i.exec(orig_link)[2];
        paper_type = /\.com\.cn\/([^\/]+)/i.exec(orig_link)[1];

        return wanfangMirrorBaseUrl + "/D/" + paper_type + "_" + paper_id + ".aspx";
    }
    else if (/\.wanfangdata\.com\.cn\/details\/detail\.do\?[^#]+$/i.test(orig_link)) {
        // 如果设置了万方镜像地址，增加跳转到镜像按钮
        // sample url (wanfang): http://www.wanfangdata.com.cn/details/detail.do?_type=perio&id=gdhg201804060
        // sample url (mirror): http://wanfang.mirror.org.cn/D/Periodical_gdhg201804060.aspx

        // sample url (wanfang): http://d.wanfangdata.com.cn/Thesis/Y1166736

        // sample url (wanfang): http://www.wanfangdata.com.cn/details/detail.do?_type=degree&id=Y1166736
        // sample url (mirror): http://wanfang.mirror.org.cn/D/Thesis_Y1166736.aspx
        // sample url (mirror pdf): http://wanfang.mirror.org.cn/Service/File/download/Thesis_Y1166736.aspx

        // sample url (wanfang): http://www.wanfangdata.com.cn/details/detail.do?_type=conference&id=8164025

        // sample url (wrong): http://www.wanfangdata.com.cn/details/detail.do?_type=degree&id=Y783863#


        paper_id = /id=([^&]+)/i.exec(orig_link)[1];
        paper_type = /_type=([^&]+)/i.exec(orig_link)[1];

        switch (paper_type) {
            case "perio":
                return wanfangMirrorBaseUrl + "/D/Periodical_" + paper_id + ".aspx";
                break;
            case "degree":
                return wanfangMirrorBaseUrl + "/D/Thesis_" + paper_id + ".aspx";
                break;
            case "conference":
                return wanfangMirrorBaseUrl + "/D/Conference_" + paper_id + ".aspx";
                break;
            case "patent":
                return wanfangMirrorBaseUrl + "/D/Patent_" + paper_id + ".aspx";
                break;
            default:
                return wanfangMirrorBaseUrl + "/D/Periodical_" + paper_id + ".aspx";
        }
    }
    return "";
}

var getSciHubLink = function (orig_link) {

    var sciHubUrl = "";

    var link_type;

    // 适配doi链接
    if (/^https?:\/\/(dx\.)?doi\.org\/10/i.test(orig_link)||
        /^https?:\/\/doi\.ieeecomputersociety\.org\//i.test(orig_link)) {

        paper_id = /.org\/([^&]+)/i.exec(orig_link)[1];
        return sciHubBaseUrl + paper_id;
    }

    // Provide direct link for open access journal
    // 开放获取期刊提供直接下载链接
    else if (/^https?:\/\/(\w+\.)?biomedcentral\.com\/\d+-\d+\/\d+\/\d+(\/abstract)?(\?fmt_view=\w+)?$/i.test(orig_link)) {
        // original url: http://www.biomedcentral.com/1471-2164/9/312
        // pdf url: https://bmcgenomics.biomedcentral.com/track/pdf/10.1186/1471-2164-9-312
        // epub url: https://bmcgenomics.biomedcentral.com/track/epub/10.1186/1471-2164-9-312

        paper_id = /com\/([\/-\d+]+\d)/i.exec(orig_link)[1];
        paper_id = paper_id.replace(/\//g, "-");

        return sciHubBaseUrl + paper_id;
    } else if (/^https?:\/\/(\w+\.)?biomedcentral\.com\/articles\/[^#]+$/i.test(orig_link)) {
        // original url: https://ehjournal.biomedcentral.com/articles/10.1186/s12940-018-0403-0
        // pdf url: https://ehjournal.biomedcentral.com/track/pdf/10.1186/s12940-018-0403-0
        // epub url: https://ehjournal.biomedcentral.com/track/epub/10.1186/s12940-018-0403-0

        paper_id = /articles\/([^&]+)$/i.exec(orig_link)[1];

        return sciHubBaseUrl + paper_id;
    } else if (/^https?:\/\/(\w+\.)?plos\.org\/\w+\/article\?id=[^#]+$/i.test(orig_link)) {
        // original url: http://journals.plos.org/plosone/article?id=10.1371/journal.pone.0131667
        // pdf url: http://journals.plos.org/plosone/article/file?id=10.1371/journal.pone.0131667&type=printable
        // original url: http://journals.plos.org/plosbiology/article?id=10.1371/journal.pbio.2005206
        // pdf url: http://journals.plos.org/plosone/article/file?id=10.1371/journal.pone.0199542&type=printable
        // original url: http://www.plosone.org/article/info%3Adoi%2F10.1371%2Fjournal.pone.0061505
        // original url 2: http://journals.plos.org/plosone/article?id=10.1371/journal.pone.0061505
        // pdf url: http://journals.plos.org/plosone/article/file?id=10.1371/journal.pone.0061505&type=printable

        paper_id = /article\?id=([^&]+)/i.exec(orig_link)[1];

        return sciHubBaseUrl + paper_id;
    } else if (/\.plosjournals\.org\/plosonline\/\?request=get-document&doi=/i.test(orig_link)) {
        // original url: http://biology.plosjournals.org/plosonline/?request=get-document&doi=10.1371/journal.pbio.0000005

        paper_id = /doi=([^&]+)/i.exec(orig_link)[1];

        return sciHubBaseUrl + paper_id;
    } else if (/^https?:\/\/(\w+\.)?frontiersin\.org\/articles\/[^#]*?(\/)?(full|pdf|epub)?$/i.test(orig_link)) {
        // original url: https://www.frontiersin.org/articles/10.3389/fmicb.2016.02108/full
        // original url: https://www.frontiersin.org/articles/10.3389/fmicb.2016.02108/pdf
        // https://www.frontiersin.org/articles/10.3389/fmicb.2012.00410
        // pdf url: https://www.frontiersin.org/articles/10.3389/fmicb.2016.02108/pdf
        // epub url: https://www.frontiersin.org/articles/10.3389/fmicb.2016.02108/epub

        paper_id = /articles\/([^#]*?)(\/)?(full|pdf|epub)?$/i.exec(orig_link)[1];

        return sciHubBaseUrl + paper_id;
    }

    // 网址包含 pubmed
    else if (/^https?:\/\/(\w+\.)?biomedcentral\.com\/pubmed\/\d+$/i.test(orig_link)) {
        // http://www.biomedcentral.com/pubmed/14574411

        paper_id = /\/pubmed\/(\d+)/i.exec(orig_link)[1];

        sciHubUrl = sciHubBaseUrl + "https://www.ncbi.nlm.nih.gov/pubmed/" + paper_id;

        return sciHubUrl;
    } else if (/^https?:\/\/(www\.)?pnas\.org\/lookup\/external-ref\?/i.test(orig_link) ||
               /^https?:\/\/(\w+\.)?bmj\.com\/(lookup\/)?external-ref\?/i.test(orig_link) ||
               /^https?:\/\/([-\w]+\.)?oxfordjournals\.org\/(lookup\/)?external-ref\?/i.test(orig_link)) {
        //PNAS.org
        // http://www.pnas.org/lookup/external-ref?access_num=10.1016/j.cell.2009.02.007&link_type=DOI
        // http://www.pnas.org/lookup/external-ref?access_num=19745823&link_type=MED&atom=%2Fpnas%2F108%2F27%2F11063.atom

        // http://femsle.oxfordjournals.org/lookup/external-ref?access_num=10.1021/es702304c&link_type=DOI
        // http://dnaresearch.oxfordjournals.org/external-ref?access_num=10.1186/1471-2164-9-312&link_type=DOI
        // http://intl-aobpla.oxfordjournals.org/external-ref?access_num=10.1186/1471-2164-6-23&link_type=DOI
        // http://gut.bmj.com/lookup/external-ref?access_num=10.1186/1471-2164-13-341&link_type=DOI
        // http://gut.bmj.com/external-ref?access_num=19144180&link_type=MED

        paper_id = /access_num=([^&]+)/i.exec(orig_link)[1];
        link_type = /link_type=([^&]+)/i.exec(orig_link)[1];

        if (link_type == "MED") {
            sciHubUrl = sciHubBaseUrl + "https://www.ncbi.nlm.nih.gov/pubmed/" + paper_id;
        } else {
            sciHubUrl = sciHubBaseUrl + paper_id;
        }
        return sciHubUrl;
    } else if (/^https?:\/\/(\w+\.)?wiley\.com\/resolve\/reference\/\w+\?id=/i.test(orig_link)) {
        // Wiley
        // http://onlinelibrary.wiley.com/resolve/reference/PMED?id=6396500
        // http://onlinelibrary.wiley.com/resolve/reference/XREF?id=10.1186/1471-2164-8-242

        paper_id = /\?id=([^&]+)/i.exec(orig_link)[1];
        link_type = /reference\/([^&]+)\?id=/i.exec(orig_link)[1];

        if (link_type == "PMED") {
            sciHubUrl = sciHubBaseUrl + "https://www.ncbi.nlm.nih.gov/pubmed/" + paper_id;
        } else {
            sciHubUrl = sciHubBaseUrl + paper_id;
        }
        return sciHubUrl;
    }

    // url contains doi
    // 网址包含doi
    else if (/\/doi(\/abs|full|pdf|ref)?\/([^#&]+)$/i.test(orig_link)) {
        // worldscientific
        // http://www.worldscientific.com/doi/abs/10.1142/9789814542319_0026
        // https://www.physiology.org/doi/abs/10.1152/physiolgenomics.00005.2015
        // http://physiolgenomics.physiology.org/content/early/2015/04/21/physiolgenomics.00005.2015
        // http://www.tandfonline.com/doi/full/10.1080/09513590.2017.1407753
        // https://pubs.acs.org/doi/full/10.1021/cen-09712-polcon1?ref=PubsWidget
        // http://pubs.acs.org/doi/abs/10.1021/es802721d

        paper_id = /doi(\/abs|full|pdf|ref)?\/([^#&\?]+)/i.exec(orig_link)[2];
        sciHubUrl = sciHubBaseUrl + paper_id;
        return sciHubUrl;
    } else if (/\/servlet\/linkout\?suffix=/i.test(orig_link)) {
        // http://www.thelancet.com/servlet/linkout?suffix=e_1_4_1_2_2_2&dbid=16&doi=10.1016/S0140-6736(01)07112-4&key=10.1161%2Fhc3901.095896&cf=
        // http://www.cell.com/servlet/linkout?suffix=e_1_5_1_2_31_2&amp;dbid=16&amp;doi=10.1016/j.chom.2015.01.014&amp;key=10.1186%2F1471-2164-13-341&amp;cf=
        // https://www.tandfonline.com/servlet/linkout?suffix=CIT0015&dbid=8&doi=10.1080%2F09513590.2017.1407753&key=686083
        paper_id = /doi=([^&]+)/i.exec(orig_link)[1];
        sciHubUrl = sciHubBaseUrl + paper_id;
        return sciHubUrl;
    } else if (/^https?:\/\/www\.springerlink\.com\/content\/fulltext\.pdf\?id=doi:/i.test(orig_link)) {
        // http://www.springerlink.com/content/fulltext.pdf?id=doi:10.1007/978-3-319-31248-4_6
        // http://www.springerlink.com/content/978-3-642-22600-7 --> https://link.springer.com/book/10.1007%2F978-3-642-22600-7
        paper_id = /doi:([^&]+)/i.exec(orig_link)[1];
        sciHubUrl = sciHubBaseUrl + paper_id;
        return sciHubUrl;
    } else if (/^https:\/\/doi\.org\/openurl\?/i.test(orig_link)) {
        // http://dx.doi.org/openurl?url_ver=Z39.88-2004&rft_id=info:doi/10.1007/s40313-014-0139-1&rfr_id=info:id/deepdyve.com:deepdyve
        paper_id = /rft_id=info:doi\/([^&]+)/i.exec(orig_link)[1];
        sciHubUrl = sciHubBaseUrl + paper_id;
        return sciHubUrl;
    } else if (/^https:\/\/journals\.aps\.org\/\w+\/abstract\//i.test(orig_link)) {
        // https://journals.aps.org/prl/abstract/10.1103/PhysRevLett.127.041301
        // https://journals.aps.org/prfluids/abstract/10.1103/PhysRevFluids.6.070001
        paper_id = /(10\..*)$/i.exec(orig_link)[0];
        sciHubUrl = sciHubBaseUrl + paper_id;
        return sciHubUrl;
    }

    // url contains pmid
    // 网址包含pmid
    else if (/^https?:\/\/(\w+\.)?ncbi\.nlm\.nih\.gov\/pmc\/articles\/pmid\/\d+\/?$/i.test(orig_link)) {
        //ncbi
        //https://www.ncbi.nlm.nih.gov/pmc/articles/pmid/22555592/

        paper_id = /pmid\/(\d+)/i.exec(orig_link)[1];
        sciHubUrl = sciHubBaseUrl + "https://www.ncbi.nlm.nih.gov/pubmed/" + paper_id;
        return sciHubUrl;
    } else if (/^https?:\/\/(pubmed\.)?ncbi\.nlm\.nih\.gov\/\d+([?\/][^#]+)?/i.test(orig_link)) {
        //ncbi
        // https://pubmed.ncbi.nlm.nih.gov/30116470/?from_term=micro-ct&from_pos=2
        // https://pubmed.ncbi.nlm.nih.gov/24275269/

        paper_id = /ncbi\.nlm\.nih\.gov\/(\d+)/i.exec(orig_link)[1];
        sciHubUrl = sciHubBaseUrl + "https://www.ncbi.nlm.nih.gov/pubmed/" + paper_id;
        return sciHubUrl;
    } else if (/^https?:\/\/(\w+\.)?pubmed\.com\//i.test(orig_link)) {
        //http://pubmed.com/30001218

        paper_id = /pubmed\.com\/(\d+)/i.exec(orig_link)[1];
        sciHubUrl = sciHubBaseUrl + "https://www.ncbi.nlm.nih.gov/pubmed/" + paper_id;
        return sciHubUrl;
    } else if (/^https?:\/\/(\w+\.)?europepmc\.org\/abstract\/med\/\d+/i.test(orig_link)) {
        // https://europepmc.org/abstract/med/6683475

        paper_id = /med\/(\d+)/i.exec(orig_link)[1];
        sciHubUrl = sciHubBaseUrl + "https://www.ncbi.nlm.nih.gov/pubmed/" + paper_id;
        return sciHubUrl;
    } else if (/^https?:\/\/(\w+\.)?sciencemag\.org\/cgi\/pmidlookup\?/i.test(orig_link) ||
               /^https?:\/\/(\w+\.)?bmj\.com\/cgi\/pmidlookup\?/i.test(orig_link)) {
        //sciencemag
        //http://stm.sciencemag.org/cgi/pmidlookup?view=short&pmid=22932225&intcmp=trendmd-stm

        //bmj
        //http://gut.bmj.com/cgi/pmidlookup?view=short&pmid=21561876&int_source=trendmd&int_medium=trendmd&int_campaign=trendmd

        paper_id = /pmid=([^&]+)/i.exec(orig_link)[1];
        sciHubUrl = sciHubBaseUrl + "https://www.ncbi.nlm.nih.gov/pubmed/" + paper_id;
        return sciHubUrl;
    } else if (/^https?:\/\/med\.wanfangdata\.com\.cn\/Paper\/Detail\/PeriodicalPaper_PM\d+$/i.test(orig_link)) {
        //万方pubmed跳转

        paper_id = /PeriodicalPaper_PM([^&#]+)/i.exec(orig_link)[1];
        sciHubUrl = sciHubBaseUrl + "https://www.ncbi.nlm.nih.gov/pubmed/" + paper_id;
        return sciHubUrl;
    } else if (/^https?:\/\/(\w+\.)?ncbi\.nlm\.nih\.gov\/[\w\.\/]+\?cmd=Retrieve[^#]+$/i.test(orig_link)) {
        //ncbi
        // http://www.ncbi.nlm.nih.gov/entrez/query.fcgi?cmd=Retrieve&db=PubMed&dopt=Abstract&list_uids=21959244
        // https://www.ncbi.nlm.nih.gov/pubmed?cmd=Retrieve&dopt=Abstract&list_uids=12148636
        paper_id = /list_uids=([^&]+)/i.exec(orig_link)[1];
        sciHubUrl = sciHubBaseUrl + "https://www.ncbi.nlm.nih.gov/pubmed/" + paper_id;
        return sciHubUrl;
    } else if (/^https?:\/\/(\w+\.)?pubmed.cn\/\d+$/i.test(orig_link)) {
        //ncbi
        //http://pubmed.cn/27161352

        paper_id = /\/(\d+)/i.exec(orig_link)[1];
        sciHubUrl = sciHubBaseUrl + "https://www.ncbi.nlm.nih.gov/pubmed/" + paper_id;
        return sciHubUrl;
    }

    // url contains PMCid
    // 网址包含PMCid
    else if (/^https?:\/\/(www\.)?ncbi\.nlm\.nih\.gov\/pmc\/articles\/PMC\d+\/?$/i.test(orig_link) ||
             /^https?:\/\/(www\.)?europepmc\.org\/(articles|abstract)\/PMC\d+\/?$/i.test(orig_link) ||
             /^https?:\/\/(www\.)?pubmedcentralcanada\.ca\/pmcc\/articles\/PMC\d+\/?$/i.test(orig_link) ||
             /^https?:\/\/(www\.)?pubmedcentralcanada\.ca\/articlerender\.cgi\?accid=PMC[^#]+$/i.test(orig_link)) {
        // PMC
        // europepmc
        // http://europepmc.org/articles/PMC2483731/

        //pubmedcentralcanada
        //http://pubmedcentralcanada.ca/pmcc/articles/PMC5166555

        // PubMed Central Canada website is now closed permanently
        // This article is no longer available through PubMedCentral Canada.
        // All manuscripts along with all other content remain publicly searchable on PubMed Central (US) and Europe PubMed Central.
        // Approximately 3,000 manuscripts authored by Canadian Institutes of Health Research (CIHR)-funded researchers have
        // now also been added the National Research Council’s (NRC) Digital Repository and form the Canadian Institutes of Health Research 2009-2017 Collection.

        paper_id = /(PMC\d+)/i.exec(orig_link)[1];
        sciHubUrl = sciHubBaseUrl + "https://www.ncbi.nlm.nih.gov/pmc/articles/" + paper_id;
        return sciHubUrl;
    } else if (/^https?:\/\/(\w+\.)?pubmedcentral\.nih\.gov\/picrender\.fcgi\?/i.test(orig_link)) {
        //ncbi
        //http://www.pubmedcentral.nih.gov/picrender.fcgi?artid=PMC1784667&blobtype=pdf

        paper_id = /artid=([^&]+)/i.exec(orig_link)[1];
        sciHubUrl = sciHubBaseUrl + "https://www.ncbi.nlm.nih.gov/pmc/articles/" + paper_id;
        return sciHubUrl;
    } else if (/^https?:\/\/(www\.)?ajas\.info\/journal\/view.php\?number=\d+$/i.test(orig_link) ||
               /^https?:\/\/(\w+\.)?bmj\.com\/content\/.*\d((\.short)|(\?.*))$/i.test(orig_link) ||
               /^https?:\/\/(\w+\.)?cabdirect\.org\/[^#]+.html$/i.test(orig_link) ||
               /^https?:\/\/(\w+\.)?cambridge\.org\/(article|abstract)[^#]+$/i.test(orig_link) ||
               /^https?:\/\/(\w+\.)?cambridge\.org\/core\/journals\/[^#]+$/i.test(orig_link) ||
               /^https?:\/\/(\w+\.)?europepmc\.org\/abstract\/[^#\?]+$/i.test(orig_link) ||
               /^https?:\/\/(\w+\.)?ieee\.org\/xpls\/abs_all\.jsp\?arnumber=\d+\/?$/i.test(orig_link) ||
               /^https?:\/\/(\w+\.)?ieee\.org\/document\/\d+\/?$/i.test(orig_link) ||
               /^https?:\/\/(\w+\.)?ieee\.org\/abstract\/document\/\d+\/?$/i.test(orig_link) ||
               // https://ieeexplore.ieee.org/abstract/document/7523636
               /^https?:\/\/(\w+\.)?jstor\.org\/stable\/[^#]+$/i.test(orig_link) ||
               /^https?:\/\/(\w+\.)?nature\.com\/\w+\/journal\/[^#]+[^(index)].html$/i.test(orig_link) ||
               /^https?:\/\/(\w+\.)?nature\.com\/articles\/[\w\.-]+(\.pdf)?(\?origin=\w+)?\/?$/i.test(orig_link) ||

               // https://www.nature.com/articles/nrmicro2372.pdf?origin=ppub
               /^https?:\/\/(\w+\.)?onlinelibrary\.wiley\.com\/doi\/[^#]+$/i.test(orig_link) ||
               /^https?:\/\/(\w+\.)?pnas\.org\/content\/\d+\/\d+\/\w+\d+(\.full)?\/?$/i.test(orig_link) ||
               /^https?:\/\/(\w+\.)?pnas\.org\/content\/(early\/)?\d+\/\d+\/\d+\/?\d+?(\.short)?$/i.test("") ||
               // https://www.pnas.org/content/early/2020/06/23/1921186117
               // https://www.pnas.org/content/108/27/11063.short

               // /^https?:\/\/(\w+\.)?researchgate\.net\/publication\/[^#]+$/i.test(orig_link) ||
               /^https?:\/\/(\w+\.)?sciencedirect\.com\/science\/article\/[^#]+$/i.test(orig_link) ||
               /^https?:\/\/(\w+\.)?sciencemag\.org\/content\/\d+\/\d+\/\w+\d+\/?$/i.test(orig_link) ||
               /^https?:\/\/(\w+\.)?springer\.com\/(article|chapter|content|book)\/[^#]+$/i.test(orig_link) ||
               /^https?:\/\/(\w+\.)?springer\.com\/10\.[^#]+$/i.test(orig_link) ||
               /^https?:\/\/(\w+\.)?thelancet\.com\/journals\/\w+\/article.*\/fulltext\/?$/i.test(orig_link) ||
               /^https?:\/\/(\w+\.)?wiley\.com\/doi\/[^#]+$/i.test(orig_link) ||
               /^https?:\/\/(www\.)?ncbi\.nlm\.nih\.gov\/pubmed\/\d+([?\/][^#]+)?$/i.test(orig_link) ||
               //                /^https?:\/\/(\w+\.)?\w+\.com\/article\/[\w-\(\)]+\/fulltext$/i.test(orig_link) ||
               /^https?:\/\/dl\.acm\.org\/citation\.cfm\?id=[^#]+$/i.test(orig_link)) {
        // article: https://www.nature.com/nprot/journal/v6/n6/abs/nprot.2011.319.html
        // index: https://www.nature.com/nature/journal/v559/n7713/index.html

        return sciHubBaseUrl + orig_link;
    }
    else if (/^https?:\/\/(\w+\.)?cell\.com\/\w+\/(abstract|fulltext|retrieve|pdf)\/[^#]+$/i.test(orig_link)) {
        // https://www.cell.com/cell/fulltext/S0092-8674(18)31026-2
        // https://www.cell.com/cell/pdf/S0092-8674(18)31026-2.pdf
        return sciHubBaseUrl + orig_link.replace(".pdf","").replace("pdf","fulltext");
    }
    return "";
}

var getUnpaywallLink = function (orig_link) {

    var unpaywallUrl = "";

    var link_type;

    // 适配doi链接
    if (/^https?:\/\/(dx\.)?doi\.org\/10/i.test(orig_link)||
        /^https?:\/\/doi\.ieeecomputersociety\.org\//i.test(orig_link)) {

        paper_id = /.org\/([^&]+)/i.exec(orig_link)[1];
        return unpaywallBaseUrl + paper_id;
    }

    // Provide direct link for open access journal
    // 开放获取期刊提供直接下载链接
    else if (/^https?:\/\/(\w+\.)?biomedcentral\.com\/\d+-\d+\/\d+\/\d+(\/abstract)?(\?fmt_view=\w+)?$/i.test(orig_link)) {
        // original url: http://www.biomedcentral.com/1471-2164/9/312
        // pdf url: https://bmcgenomics.biomedcentral.com/track/pdf/10.1186/1471-2164-9-312
        // epub url: https://bmcgenomics.biomedcentral.com/track/epub/10.1186/1471-2164-9-312

        paper_id = /com\/([\/-\d+]+\d)/i.exec(orig_link)[1];
        paper_id = paper_id.replace(/\//g, "-");

        return unpaywallBaseUrl + paper_id;
    } else if (/^https?:\/\/(\w+\.)?biomedcentral\.com\/articles\/[^#]+$/i.test(orig_link)) {
        // original url: https://ehjournal.biomedcentral.com/articles/10.1186/s12940-018-0403-0
        // pdf url: https://ehjournal.biomedcentral.com/track/pdf/10.1186/s12940-018-0403-0
        // epub url: https://ehjournal.biomedcentral.com/track/epub/10.1186/s12940-018-0403-0

        paper_id = /articles\/([^&]+)$/i.exec(orig_link)[1];

        return unpaywallBaseUrl + paper_id;
    } else if (/^https?:\/\/(\w+\.)?plos\.org\/\w+\/article\?id=[^#]+$/i.test(orig_link)) {
        // original url: http://journals.plos.org/plosone/article?id=10.1371/journal.pone.0131667
        // pdf url: http://journals.plos.org/plosone/article/file?id=10.1371/journal.pone.0131667&type=printable
        // original url: http://journals.plos.org/plosbiology/article?id=10.1371/journal.pbio.2005206
        // pdf url: http://journals.plos.org/plosone/article/file?id=10.1371/journal.pone.0199542&type=printable
        // original url: http://www.plosone.org/article/info%3Adoi%2F10.1371%2Fjournal.pone.0061505
        // original url 2: http://journals.plos.org/plosone/article?id=10.1371/journal.pone.0061505
        // pdf url: http://journals.plos.org/plosone/article/file?id=10.1371/journal.pone.0061505&type=printable

        paper_id = /article\?id=([^&]+)/i.exec(orig_link)[1];

        return unpaywallBaseUrl + paper_id;
    } else if (/\.plosjournals\.org\/plosonline\/\?request=get-document&doi=/i.test(orig_link)) {
        // original url: http://biology.plosjournals.org/plosonline/?request=get-document&doi=10.1371/journal.pbio.0000005

        paper_id = /doi=([^&]+)/i.exec(orig_link)[1];

        return unpaywallBaseUrl + paper_id;
    } else if (/^https?:\/\/(\w+\.)?frontiersin\.org\/articles\/[^#]*?(\/)?(full|pdf|epub)?$/i.test(orig_link)) {
        // original url: https://www.frontiersin.org/articles/10.3389/fmicb.2016.02108/full
        // original url: https://www.frontiersin.org/articles/10.3389/fmicb.2016.02108/pdf
        // https://www.frontiersin.org/articles/10.3389/fmicb.2012.00410
        // pdf url: https://www.frontiersin.org/articles/10.3389/fmicb.2016.02108/pdf
        // epub url: https://www.frontiersin.org/articles/10.3389/fmicb.2016.02108/epub

        paper_id = /articles\/([^#]*?)(\/)?(full|pdf|epub)?$/i.exec(orig_link)[1];

        return unpaywallBaseUrl + paper_id;
    } else if (/^https?:\/\/(www\.)?pnas\.org\/lookup\/external-ref\?/i.test(orig_link) ||
               /^https?:\/\/(\w+\.)?bmj\.com\/(lookup\/)?external-ref\?/i.test(orig_link) ||
               /^https?:\/\/([-\w]+\.)?oxfordjournals\.org\/(lookup\/)?external-ref\?/i.test(orig_link)) {
        //PNAS.org
        // http://www.pnas.org/lookup/external-ref?access_num=10.1016/j.cell.2009.02.007&link_type=DOI
        // http://www.pnas.org/lookup/external-ref?access_num=19745823&link_type=MED&atom=%2Fpnas%2F108%2F27%2F11063.atom

        // http://femsle.oxfordjournals.org/lookup/external-ref?access_num=10.1021/es702304c&link_type=DOI
        // http://dnaresearch.oxfordjournals.org/external-ref?access_num=10.1186/1471-2164-9-312&link_type=DOI
        // http://intl-aobpla.oxfordjournals.org/external-ref?access_num=10.1186/1471-2164-6-23&link_type=DOI
        // http://gut.bmj.com/lookup/external-ref?access_num=10.1186/1471-2164-13-341&link_type=DOI
        // http://gut.bmj.com/external-ref?access_num=19144180&link_type=MED

        paper_id = /access_num=([^&]+)/i.exec(orig_link)[1];
        link_type = /link_type=([^&]+)/i.exec(orig_link)[1];

        if (link_type == "DOI") {
            unpaywallUrl = unpaywallBaseUrl + paper_id;
        }
        return unpaywallUrl;
    } else if (/^https?:\/\/(\w+\.)?wiley\.com\/resolve\/reference\/\w+\?id=/i.test(orig_link)) {
        // Wiley
        // http://onlinelibrary.wiley.com/resolve/reference/PMED?id=6396500
        // http://onlinelibrary.wiley.com/resolve/reference/XREF?id=10.1186/1471-2164-8-242

        paper_id = /\?id=([^&]+)/i.exec(orig_link)[1];
        link_type = /reference\/([^&]+)\?id=/i.exec(orig_link)[1];

        if (link_type != "PMED") {
            unpaywallUrl = unpaywallBaseUrl + paper_id;
        }
        return unpaywallUrl;
    }

    // url contains doi
    // 网址包含doi
    else if (/\/doi\/(abs|full|pdf|ref)\/([^#&]+)$/i.test(orig_link)) {
        // worldscientific
        // http://www.worldscientific.com/doi/abs/10.1142/9789814542319_0026
        // https://www.physiology.org/doi/abs/10.1152/physiolgenomics.00005.2015
        // http://physiolgenomics.physiology.org/content/early/2015/04/21/physiolgenomics.00005.2015
        // http://www.tandfonline.com/doi/full/10.1080/09513590.2017.1407753
        // https://pubs.acs.org/doi/full/10.1021/cen-09712-polcon1?ref=PubsWidget
        // http://pubs.acs.org/doi/abs/10.1021/es802721d

        paper_id = /doi\/(abs|full|pdf|ref)\/([^#&\?]+)/i.exec(orig_link)[2];
        unpaywallUrl = unpaywallBaseUrl + paper_id;
        return unpaywallUrl;
    } else if (/\/servlet\/linkout\?suffix=/i.test(orig_link)) {
        // http://www.thelancet.com/servlet/linkout?suffix=e_1_4_1_2_2_2&dbid=16&doi=10.1016/S0140-6736(01)07112-4&key=10.1161%2Fhc3901.095896&cf=
        // http://www.cell.com/servlet/linkout?suffix=e_1_5_1_2_31_2&amp;dbid=16&amp;doi=10.1016/j.chom.2015.01.014&amp;key=10.1186%2F1471-2164-13-341&amp;cf=
        // https://www.tandfonline.com/servlet/linkout?suffix=CIT0015&dbid=8&doi=10.1080%2F09513590.2017.1407753&key=686083
        paper_id = /doi=([^&]+)/i.exec(orig_link)[1];
        unpaywallUrl = unpaywallBaseUrl + paper_id;
        return unpaywallUrl;
    } else if (/^https?:\/\/www\.springerlink\.com\/content\/fulltext\.pdf\?id=doi:/i.test(orig_link)) {
        // http://www.springerlink.com/content/fulltext.pdf?id=doi:10.1007/978-3-319-31248-4_6
        // http://www.springerlink.com/content/978-3-642-22600-7 --> https://link.springer.com/book/10.1007%2F978-3-642-22600-7
        paper_id = /doi:([^&]+)/i.exec(orig_link)[1];
        unpaywallUrl = unpaywallBaseUrl + paper_id;
        return unpaywallUrl;
    } else if (/^https:\/\/doi\.org\/openurl\?/i.test(orig_link)) {
        // http://dx.doi.org/openurl?url_ver=Z39.88-2004&rft_id=info:doi/10.1007/s40313-014-0139-1&rfr_id=info:id/deepdyve.com:deepdyve
        paper_id = /rft_id=info:doi\/([^&]+)/i.exec(orig_link)[1];
        unpaywallUrl = unpaywallBaseUrl + paper_id;
        return unpaywallUrl;
    } else if (/^https:\/\/journals\.aps\.org\/\w+\/abstract\//i.test(orig_link)) {
        // https://journals.aps.org/prl/abstract/10.1103/PhysRevLett.127.041301
        // https://journals.aps.org/prfluids/abstract/10.1103/PhysRevFluids.6.070001
        paper_id = /(10\..*)$/i.exec(orig_link)[0];
        unpaywallUrl = unpaywallBaseUrl + paper_id;
        return unpaywallUrl;
    }

    return "";
}

function addScihubIco(sciHubUrl, documentId, ico) {

    sciHubLink = document.createElement('a');
    sciHubLink.href = sciHubUrl;
    documentId.parentNode.insertBefore(sciHubLink, documentId.nextSibling);

    sciHubLinkIMG = document.createElement('img');
    sciHubLinkIMG.setAttribute("id", "imgCheck");
    sciHubLinkIMG.setAttribute("src", ico);
    sciHubLinkIMG.setAttribute("style", "height: 15px !important;width: 15px !important; margin: 2px !important; display: inline-block;");
    sciHubLink.appendChild(sciHubLinkIMG);
}

function addVipDownloadIco(vipUrl, documentId, ico) {
    // original url: http://www.cqvip.com/QK/90266B/20184/675514129.html
    // download url: http://www.cqvip.com/main/confirm.aspx?id=675514129


    // original url: http://www.cqvip.com/Main/DetailAdd.aspx?id=458
    // download url: http://down.cqvip.com/main/downaj.aspx?id=458

    var vipLink = document.createElement('a');
    vipLink.href = vipUrl.replace(/http:\/\/(www\.)?cqvip.com\/QK\/\w+\/\d+\/(\d+)\.html/g, "http://www.cqvip.com/main/confirm.aspx?id=$2").replace("http://www.cqvip.com/Main/DetailAdd.aspx?id=","http://down.cqvip.com/main/downaj.aspx?id=");
    vipLink.setAttribute("style", "background-position:0px -120px; display:block;float:left;width:120px;height:40px;margin:0 5px 0 auto;background:url('/css/zcps/img/detail_btn_2012.png') no-repeat;border:none;text-indent:-9999px;cursor:pointer;");
    documentId.parentNode.insertBefore(vipLink, documentId.nextSibling);
}

function addFloatBox(floatLink, ico) {
    //make float box
    var box = document.createElement('div');
    box.id = 'sciHubButton';

    addGlobalStyle(
        ' #sciHubButton {             ' +
        '    position: fixed;    ' +
        '    top: 100px; left: 100px;   ' +
        '    max-width: 400px;      ' +
        '    z-index: 999;      ' +
        ' } ');
    box.innerHTML = "<a href=\"" + floatLink + "\"><img id=\"imgCheck\" src=\"" + ico + "\" style=\"height: 30px !important; width: 30px !important; margin: 2px !important; display: inline-block;\"></a>";
    document.body.appendChild(box);

}

if(vipAutoDownload && site.includes("http://www.cqvip.com/main/export.aspx?id=")){
    document.getElementsByClassName("getfile")[0].firstChild.nextSibling.firstChild.click();
    //     window.close();
}
else{
    window.addEventListener('load', floatBox);
    window.addEventListener('load', replaceDOIsWithLinks);
    window.addEventListener('load', makeLinkClickable);
    window.addEventListener('load', modifyLink);
    window.addEventListener('load', translateSciHub);
}
