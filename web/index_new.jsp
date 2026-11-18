<%-- 
    Document   : index_new
    Created on : 26.01.2025, 15:32:21
    Author     : bernd
--%>

<%@page import="java.util.Objects"%>
<%@page import="java.util.Random"%>
<%@page import="java.util.ResourceBundle"%>
<%@page import="java.io.File"%>
<%@page import="org.zumult.backend.BackendInterfaceFactory"%>
<%@page import="org.zumult.backend.BackendInterface"%>
<%@page import="org.zumult.backend.Configuration"%>
<%@page import="org.zumult.objects.Transcript"%>
<%@page import="org.zumult.objects.Corpus"%>
<%@page import="org.zumult.objects.IDList"%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<%@include file="../WEB-INF/jspf/locale.jspf" %>     
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1">        
        <link  rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.8/dist/css/bootstrap.min.css">
        
        <script src="https://code.jquery.com/jquery-3.4.1.min.js" integrity="sha256-CSXorXvZcTkaix6Yvo6HppcZGetbYMGWSFlBw8HfCJo="crossorigin="anonymous"></script>        
        <script src="https://kit.fontawesome.com/ed5adda70b.js" crossorigin="anonymous"></script>
        <script src="https://cdn.jsdelivr.net/npm/popper.js@1.16.0/dist/umd/popper.min.js" integrity="sha384-Q6E9RHvbIyZFJoft+2mJbHaEWldlvI9IOYy5n3zV9zzTtmI3UksdQRVvoxMfooAo" crossorigin="anonymous"></script>        
        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.8/dist/js/bootstrap.bundle.min.js"></script>
        
        <title>ZuMult - Transcription+ instance @ AdWHH</title>
        <style type="text/css">
            .wrapper {
                display: flex;
                width: 100%;
                align-items: stretch;
            }           
            #sidebar {
                min-width: 250px;
                max-width: 250px;

            }            
            .footer-logo {
                max-height: 45px;
                width: auto;
                max-width: 160px;
                object-fit: contain;
            }            
            
            .overview-section {
                display: flex;
                align-items: stretch;
                gap: 1rem;
            }

            .overview-section-title {
                flex: 0 0 48px;
                display: flex;
                align-items: center;
                justify-content: center;
                border-right: 1px solid rgba(66, 88, 59, .35);
            }

            .overview-section-title h2 {
                writing-mode: vertical-rl;
                transform: rotate(180deg);
                margin: 0;
                font-size: 1.15rem;
                font-weight: 500;
                text-transform: uppercase;
                letter-spacing: .14em;
                color: #42583b;
                white-space: nowrap;
            }

            .overview-section-content {
                flex: 1;
                min-width: 0;
            }            
            
        </style>
        
        <link rel="stylesheet" href="css/overview.css"/>       
        
        
        <script>
            $(document).ready(function(){
        
                $("#selectLang").on("change", function(){
                    var value = $(this).val();
                    var urlTest = new URL(window.location.href);
                    urlTest.searchParams.set('lang',value);
                    window.location = urlTest;
                });
            });
                        
        </script>
        
    </head>
    
    <%
       String pageTitle = "Transcription+ instance @ AdWHH"; 
       BackendInterface bi = BackendInterfaceFactory.newBackendInterface();
       Random random = new Random();
       IDList allCorpusIDs = bi.getCorpora();
       String corpusID = null; // needed to inform menu bar
       String randomCorpusID = allCorpusIDs.get(random.nextInt(allCorpusIDs.size()));
       IDList allTranscriptIDs =  bi.getTranscripts4Corpus(randomCorpusID);
       String randomTranscriptID = allTranscriptIDs.get(random.nextInt(allTranscriptIDs.size()));
       Transcript transcript = bi.getTranscript(randomTranscriptID);
       String randomAnnotationBlockID = transcript.getFirstAnnotationBlockIDForTime(10.0);
       String transcriptID = null; // needed to inform menu bar
    %>

    <body style="margin-top: 80px; background: rgb(220, 238, 207)">
        
        <% String pageName = "ZuMult"; %>
        <%@include file="../WEB-INF/jspf/zumultNav.jspf" %>   
        
        <div class="container-fluid px-5">
            <%@include file="../WEB-INF/jspf/welcomeJumboUHH.jspf" %>   

            <div class="container-fluid py-4">

                <!-- CORPORA -->
                <section class="overview-section mb-5">
                    <div class="overview-section-title">
                        <h2>Corpora</h2>
                    </div>
                    <div class="d-flex flex-nowrap gap-3 overflow-auto pb-3">

                        <% 
                            for (String cID : allCorpusIDs){
                            Corpus corpus = bi.getCorpus(cID);
                            String corpusName = corpus.getName(pageParam_lang);
                            String corpusImgSrc = "./images/words.jpg";
                            String tryPath = "/images/corpora/" + cID + ".png";
                            System.out.println("Trying " + tryPath);
                            String path = request.getSession().getServletContext().getRealPath(tryPath);
                            if (path!=null){
                                File image = new File(path);    
                                if (image.exists()){
                                    corpusImgSrc = "." + tryPath;
                                }
                            }     
                            String corpusDesc = corpus.getDescription(pageParam_lang);
                        %>    
                        <div class="card corpus-card flex-shrink-0 p-3"
                             data-corpus-id="<%= cID %>"
                             style="width: 300px; cursor: pointer;">
                            <img src="<%= corpusImgSrc %>" class="card-img-top d-block mx-auto" alt="Corpus image" style="width:200px;">
                            <div class="card-body">
                                <h5 class="card-title fs-5"><%= corpusName %></h5>
                            </div>
                            <div class="collapse" id="fullCorpusDescription_<%= cID %>">
                                <p class="card-text">
                                    <%= corpusDesc %>
                                </p>
                            </div>  
                            <a class="text-decoration-none"
                               data-bs-toggle="collapse"
                               href="#fullCorpusDescription_<%= cID %>"
                               role="button"
                               aria-expanded="false"
                               aria-controls="corpusDescriptionTGDP">
                                Read more
                            </a>                            
                        </div>
                        <% } %>

                        <!-- More corpus cards -->

                    </div>
                </section>

                <!-- MAIN APPLICATIONS -->
                <section class="overview-section mb-3">
                    <div class="overview-section-title">
                        <h2>Main Applications</h2>
                    </div>                    

                    <div class="d-flex flex-wrap gap-3">

                        <!-- ZuGang -->
                        <div class="card" style="width: 500px;">
                            <div class="card-body d-flex flex-column">
                                <h5 class="card-title" title="Zugang zur Gesamtheit aller notwendigen Grundinformationen"><i class="fa-solid fa-layer-group" aria-hidden="true"></i> ZuGang <span class="text-muted">- Corpora</span></h5>
                                
                                <a id="zugang-link-img" href="jsp/zuGang.jsp?corpusID=<%= randomCorpusID %>"> 
                                    <img src="./images/start-zugang.png" class="card-img-top start my-3" alt="ZuGang screenshot" 
                                         style="width:450px; border: 2px solid gray; border-radius: 5px;"/>
                                </a>
                                
                                <p class="card-text">
                                      <%=myResources.getString("Start-ZuGang")%>
                                </p>
                                <a id="zugang-link" href="jsp/zuGang.jsp?corpusID=<%= randomCorpusID %>" 
                                   class="btn btn-primary mt-auto">Open ZuGang</a>
                            </div>
                        </div>

                        <!-- ZuRecht -->
                        <div class="card" style="width: 500px;">
                            <div class="card-body d-flex flex-column">
                                <h5 class="card-title" title="Zugang zu Recherche in Transkripten"><i class="fa-solid fa-magnifying-glass" aria-hidden="true"></i> ZuRecht <span class="text-muted">- Query</span></h5>
                                <a id="zurecht-link-img" href="jsp/zuRecht.jsp?corpusID=<%= randomCorpusID %>"> 
                                    <img src="./images/start-zurecht.png" class="card-img-top start my-3" alt="ZuRecht screenshot" 
                                         style="width:450px; border: 2px solid gray; border-radius: 5px;"/>
                                </a>
                                
                                <p class="card-text">
                                    <%=myResources.getString("STARTZurecht1")%> <b>CQP</b>. 
                                    <%=myResources.getString("STARTZurecht2")%>                                    
                                </p>
                                <a id="zurecht-link" href="jsp/zuRecht.jsp?corpusID=<%= randomCorpusID %>" 
                                   class="btn btn-primary mt-auto">Open ZuRecht</a>
                            </div>
                        </div>

                        <!-- ZuViel -->
                        <div class="card" style="width: 500px;">
                            <div class="card-body d-flex flex-column">
                                <h5 class="card-title" title="Zugang zu Visualisierungselementen für Transkripte"><i class="fa-solid fa-align-left" aria-hidden="true"></i> ZuViel <span class="text-muted">- Transcripts</span></h5>
                                <a id="zuviel-link-img" href="jsp/zuViel.jsp"> 
                                    <img src="./images/start-zuviel.png" class="card-img-top start my-3" alt="ZuViel screenshot" 
                                         style="width:450px; border: 2px solid gray; border-radius: 5px;"/>
                                </a>
                                
                                <p class="card-text">
                                    <%=myResources.getString("STARTZuviel")%>
                                </p>
                                <div class="d-flex align-items-center gap-2 mt-auto">
                                    <a id="zuviel-link"
                                       href="jsp/zuViel.jsp"
                                       class="btn btn-primary">
                                        Open ZuViel
                                    </a>
                                    <select id="zuviel-transcript-select"
                                            class="form-select w-auto">
                                        <option value="">Select corpus for list of transcripts</option>
                                    </select>
                                </div>                                
                            </div>
                        </div>

                    </div>
                </section>
                                
                <!-- SPECIAL APPLICATIONS -->
                <section class="overview-section">
                    <div class="overview-section-title">
                        <h2>Special Applications</h2>
                    </div>          
                    
                    <!-- ZuHauf -->
                    <div class="card" style="width: 300px;">
                        <div class="card-body d-flex flex-column">
                            <h5 class="card-title" title="Zugang zum Herunterladen aller unterstützten Formate"><i class="fa-solid fa-download" aria-hidden="true"></i> ZuHauf <span class="text-muted">- Downloads</span></h5>

                            <a id="zuhauf-link-img" href="jsp/zuHauf.jsp?corpusID=<%= randomCorpusID %>"> 
                                <img src="./images/start-zuhauf.png" class="card-img-top start my-3" alt="ZuHauf screenshot" 
                                     style="width:250px; border: 2px solid gray; border-radius: 5px;"/>
                            </a>

                            <p class="card-text">
                                  <%=myResources.getString("Start-ZuHauf")%>
                            </p>
                            <a id="zuhauf-link" href="jsp/zuHauf.jsp?corpusID=<%= randomCorpusID %>" 
                               class="btn btn-primary mt-auto">Open ZuHauf</a>
                        </div>
                    </div>
                    
                                
                </section>
            </div>

            <%@include file="../WEB-INF/jspf/footerUHH.jspf" %>   

        </div>
        
        <script>
                const transcriptsByCorpus = {
                    <%
                        for (int c = 0; c < allCorpusIDs.size(); c++) {
                            String cID = allCorpusIDs.get(c);
                            IDList ids = bi.getTranscripts4Corpus(cID);
                    %>
                    "<%= cID %>": [
                        <%
                            for (int t = 0; t < ids.size(); t++) {
                        %>
                        "<%= ids.get(t) %>"<%= t < ids.size() - 1 ? "," : "" %>
                        <% } %>
                    ]<%= c < allCorpusIDs.size() - 1 ? "," : "" %>
                    <% } %>
                };
    
                document.querySelectorAll('.corpus-card').forEach(card => {
                card.addEventListener('click', function(event) {

                    // Don't interfere with the "Read more" link
                    if (event.target.closest('a')) return;

                    // Remove previous selection
                    document.querySelectorAll('.corpus-card').forEach(c => {
                        c.classList.remove('selected');
                    });

                    // Select clicked corpus
                    this.classList.add('selected');

                    const corpusID = this.dataset.corpusId;
                    console.log("Selected corpus:", corpusID);
                    
                    // adjust the corpus ID parameter for ZuGang;
                    const zugangLink = document.getElementById('zugang-link');
                    const zugangLinkImg = document.getElementById('zugang-link-img');
                    if (zugangLink) {
                        const url = new URL(zugangLink.href);
                        url.searchParams.set('corpusID', corpusID);
                        zugangLink.href = url.toString();
                        if (zugangLinkImg) {
                            zugangLinkImg.href = url.toString();
                        }  
                    }  
                    // adjust the corpus ID parameter for ZuRecht;
                    const zurechtLink = document.getElementById('zurecht-link');
                    const zurechtLinkImg = document.getElementById('zurecht-link-img');
                    if (zurechtLink) {
                        const url = new URL(zurechtLink.href);
                        url.searchParams.set('corpusID', corpusID);
                        zurechtLink.href = url.toString();
                        if (zurechtLinkImg) {
                            zurechtLinkImg.href = url.toString();                        
                        }
                    }  
                    
                    // adjust the corpus ID parameter for ZuHauf;
                    const zuhaufLink = document.getElementById('zuhauf-link');
                    const zuhaufLinkImg = document.getElementById('zuhauf-link-img');
                    if (zurechtLink) {
                        const url = new URL(zuhaufLink.href);
                        url.searchParams.set('corpusID', corpusID);
                        zuhaufLink.href = url.toString();
                        if (zuhaufLinkImg) {
                            zuhaufLinkImg.href = url.toString();                        
                        }
                    }  

                    // adjust the dropdown to the selected corpus
                    const select = document.getElementById('zuviel-transcript-select');
                    select.replaceChildren();
                    for (const transcriptID of transcriptsByCorpus[corpusID] || []) {
                        select.add(new Option(transcriptID, transcriptID));
                    }                    
                    updateZuVielLink();
                    
                });
            });
            
            // Select the first corpus automatically
            document.querySelector('.corpus-card')?.click();  
            
            
            function updateZuVielLink() {
                const select = document.getElementById('zuviel-transcript-select');
                const link = document.getElementById('zuviel-link');
                const link2 = document.getElementById('zuviel-link-img');

                const url = new URL(link.href);
                url.searchParams.set('transcriptID', select.value);
                link.href = url.toString();
                link2.href = url.toString();
            }

            document.getElementById('zuviel-transcript-select').addEventListener('change', updateZuVielLink);            
        </script>        
        
    </body>
</html>
