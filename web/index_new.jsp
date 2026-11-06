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
                <section class="mb-5">
                    <h2>Corpora</h2>

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
                            <img src="<%= corpusImgSrc %>" class="card-img-top" alt="Corpus image">
                            <div class="card-body">
                                <h5 class="card-title"><%= corpusName %></h5>
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

                <!-- APPLICATIONS -->
                <section>
                    <h2>Applications</h2>

                    <div class="d-flex flex-wrap gap-3">

                        <!-- ZuGang -->
                        <div class="card" style="width: 500px;">
                            <div class="card-body d-flex flex-column">
                                <h5 class="card-title">ZuGang</h5>
                                <img src="./images/start-speechevents.png" class="card-img-top start my-3" alt="ZuGang screenshot" 
                                     style="width:450px; border: 2px solid gray; border-radius: 5px;">
                                
                                <p class="card-text">
                                      <%=myResources.getString("STARTOverviewTables")%>
                                </p>
                                <a id="zugang-link" href="jsp/zuGang.jsp?corpusID=<%= randomCorpusID %>" 
                                   class="btn btn-primary mt-auto">Open ZuGang</a>
                            </div>
                        </div>

                        <!-- ZuRecht -->
                        <div class="card" style="width: 500px;">
                            <div class="card-body d-flex flex-column">
                                <h5 class="card-title">ZuRecht</h5>
                                <img src="./images/query.png" class="card-img-top start my-3" alt="ZuRecht screenshot" 
                                     style="width:450px; border: 2px solid gray; border-radius: 5px;">
                                
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
                                <h5 class="card-title">ZuViel</h5>
                                <img src="./images/transcript2.png" class="card-img-top start my-3" alt="ZuViel screenshot" 
                                     style="width:450px; border: 2px solid gray; border-radius: 5px;">
                                
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

                            
                        <!-- More application cards -->

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
                    if (zugangLink) {
                        const url = new URL(zugangLink.href);
                        url.searchParams.set('corpusID', corpusID);
                        zugangLink.href = url.toString();
                    }  
                    
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

                const url = new URL(link.href);
                url.searchParams.set('transcriptID', select.value);
                link.href = url.toString();
            }

            document.getElementById('zuviel-transcript-select').addEventListener('change', updateZuVielLink);            
        </script>        
        
    </body>
</html>
