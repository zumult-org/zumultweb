<%-- 
    Document   : index_new
    Created on : 26.01.2025, 15:32:21
    Author     : bernd
--%>

<%@page import="org.zumult.objects.Transcript"%>
<%@page import="org.zumult.objects.IDList"%>
<%@page import="java.util.Random"%>
<%@page import="org.zumult.backend.BackendInterfaceFactory"%>
<%@page import="org.zumult.backend.BackendInterface"%>
<%@page import="java.util.ResourceBundle"%>
<%@page import="org.zumult.backend.Configuration"%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<%@include file="../WEB-INF/jspf/locale.jspf" %>     
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">        
        <link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.4.1/css/bootstrap.min.css" integrity="sha384-Vkoo8x4CGsO3+Hhxv8T/Q5PaXtkKtu6ug5TOeNV6gBiFeWPGFN9MuhOf23Q9Ifjh" crossorigin="anonymous"/>
        <script src="https://code.jquery.com/jquery-3.4.1.min.js" integrity="sha256-CSXorXvZcTkaix6Yvo6HppcZGetbYMGWSFlBw8HfCJo="crossorigin="anonymous"></script>        
        <script src="https://kit.fontawesome.com/ed5adda70b.js" crossorigin="anonymous"></script>
        <script src="https://cdn.jsdelivr.net/npm/popper.js@1.16.0/dist/umd/popper.min.js" integrity="sha384-Q6E9RHvbIyZFJoft+2mJbHaEWldlvI9IOYy5n3zV9zzTtmI3UksdQRVvoxMfooAo" crossorigin="anonymous"></script>        
        <script src="https://stackpath.bootstrapcdn.com/bootstrap/4.4.1/js/bootstrap.min.js" integrity="sha384-wfSDF2E50Y2D1uUdj0O3uMBJnjuUD4Ih7YwaYd1iqfktj0Uod8GCExl3Og8ifwB6" crossorigin="anonymous"></script>                
        <title>ZuMult - <%=myResources.getString("PrototypeApplications")%></title>
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
       String pageTitle = myResources.getString("testApp"); 
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

    <body style="margin-top: 80px;">
        
        <% String pageName = "ZuMult"; %>
        <%@include file="../WEB-INF/jspf/zumultNav.jspf" %>   
        
        <div class="container">
            <div class="jumbotron py-4" style="border-radius:10px;">
                <!-- <h4 class="display-4">Hello, world!</h4> -->
                <p class="lead">
                  <img src="<%= Configuration.getWebAppBaseURL() %>/images/cropped-ZuMult.png"
                       class="float-start float-left mx-3 mb-2"
                       style="width:60px"
                       alt="ZuMult Logo">

                  <b>ZuMult</b>
                  <%=myResources.getString("STARTIntro")%>:
                  <a target="_blank" href="https://zumult.org">zumult.org</a>
                  <span> • </span>
                  <a target="_blank" href="https://zenodo.org/communities/zumult/">ZuMult@Zenodo</a>
                  <span> • </span>
                  <a target="_blank" href="https://github.com/zumult-org">ZuMult@GitHub</a>                  
                  .
               </p>
            </div>
            <div class="row">
                <div class="col-1"></div>
                <div class="col-10">
                    <ul class="list-unstyled">
                        
                      
                      <!-- *************** -->
                      <!-- CORPUS OVERVIEW -->  
                      <!-- *************** -->
                      <li class="media">
                        <img src="./images/start-corpusoverview.png" class="mr-3 start" alt="..." 
                             style="width:480px; border: 2px solid gray; border-radius: 5px;">
                        <div class="media-body">
                          <h5 class="mt-0 mb-1"><%=myResources.getString("CorpusOverview")%></h5>
                          <p>
                              <%=myResources.getString("STARTZumultHas")%> <%= allCorpusIDs.size() %> 
                                <%=myResources.getString("CorpusPL")%>: 
                              <br/>
                              <%= String.join(" • ", allCorpusIDs) %>. <br>
                              <%=myResources.getString("STARTCorpusOverview")%>
                          </p>
                          <a href="./jsp/corpusoverview.jsp?lang=<%=currentLocale.getLanguage()%>" class="btn btn-primary float-right" target="_blank">
                                   <%=myResources.getString("CorpusOverview")%>
                          </a>
                        </div>
                      </li>
                      
                      <!-- *************** -->
                      <!-- CORPUS QUERY  -->  
                      <!-- *************** -->
                      <li class="media my-4">
                        <img src="./images/query.png" class="mr-3 start" alt="..." 
                             style="width:480px; border: 2px solid gray; border-radius: 5px;">
                        <div class="media-body">
                          <h5 class="mt-0 mb-1"><%=myResources.getString("Query")%> (ZuRecht)</h5>
                          <p>
                              <%=myResources.getString("STARTZurecht1")%> <b>CQP</b>. 
                              <%=myResources.getString("STARTZurecht2")%>
                          </p>
                          <a href="./jsp/zuRecht.jsp?lang=<%=currentLocale.getLanguage()%>" class="btn btn-primary float-right" target="_blank">
                                   <%=myResources.getString("Query")%> (ZuRecht)
                          </a>
                        </div>
                      </li>
                      


                      <!-- *************** -->
                      <!-- OVERVIEW TABLES -->  
                      <!-- *************** -->
                      <li class="media my-4">
                        <img src="./images/start-speechevents.png" class="mr-3 start" alt="..." 
                             style="width:480px; border: 2px solid gray; border-radius: 5px;">
                        <div class="media-body">
                          <h5 class="mt-0 mb-1"><%=myResources.getString("SpeechEventsPL")%> • <%=myResources.getString("SpeakersPL")%></h5>
                          <p>
                              <%=myResources.getString("STARTOverviewTables")%>
                              <br/>
                              <%=myResources.getString("STARTRandomCorpus")%>                              
                              <br/>
                              <small class="text-muted ml-2"><%= randomCorpusID %></small> 
                              <div class="float-right">
                              <a href="./jsp/speecheventstable.jsp?corpusID=<%= randomCorpusID %>" class="btn btn-primary mt-3 mr-3" target="_blank">
                                <%=myResources.getString("SpeechEventsPL")%>
                              </a>
                              <a href="./jsp/speakerstable.jsp?corpusID=<%= randomCorpusID %>" class="btn btn-primary mt-3" target="_blank">
                                <%=myResources.getString("SpeakersPL")%>
                              </a>
                              </div>
                          </p>
                        </div>
                      </li>

                      <!-- *************** -->
                      <!-- STATISTICS       -->  
                      <!-- *************** -->
                      <li class="media my-4">
                        <img src="./images/start-statistics.png" class="mr-3 start" alt="..." 
                             style="width:480px; border: 2px solid gray; border-radius: 5px;">
                        <div class="media-body">
                          <h5 class="mt-0 mb-1"><%=myResources.getString("CorpusStatistics")%></h5>
                          <p>
                              <%=myResources.getString("STARTBasicStatistics")%>                              
                              <br/>
                              <%=myResources.getString("STARTRandomCorpus")%>                              
                              <br/>
                              <small class="text-muted ml-2"><%= randomCorpusID %></small> 
                              <a href="./jsp/statistics.jsp?corpusID=<%= randomCorpusID %>" class="btn btn-primary float-right mt-3" target="_blank">
                                Corpus statistics
                              </a>
                          </p>
                        </div>
                      </li>

                      
                      <!-- *************** -->
                      <!-- TRANSCRIPT DISPLAY  -->  
                      <!-- *************** -->
                      <li class="media my-4">
                        <img src="./images/transcript2.png" class="mr-3 start" alt="..."  
                             style="width:480px; border: 2px solid gray; border-radius: 5px;">
                        <div class="media-body">
                          <h5 class="mt-0 mb-1"><%=myResources.getString("STARTZuvielTitle")%> (ZuViel)</h5>
                          <p>
                              <%=myResources.getString("STARTZuviel")%>
                              <br/>
                              <%=myResources.getString("STARTRandomTranscript")%>
                              <br/>
                              <small class="text-muted ml-2"><%= randomCorpusID %> / <%= randomTranscriptID %> </small> 
                              <a href="./jsp/zuViel.jsp?transcriptID=<%= randomTranscriptID %>" class="btn btn-primary float-right mt-3" target="_blank">
                                 <%=myResources.getString("STARTZuvielTitle")%> (ZuViel)
                              </a>
                          </p>
                        </div>
                      </li>

                      <!-- *************** -->
                      <!-- ZUMIN  -->  
                      <!-- *************** -->
                      <li class="media my-4">
                        <img src="./images/zumin.png" class="mr-3 start" alt="..."  
                             style="width:480px; border: 2px solid gray; border-radius: 5px;">
                        <div class="media-body">
                          <h5 class="mt-0 mb-1"><%=myResources.getString("STARTZuminTitle")%> (ZuMin)</h5>
                          <p>
                              <%=myResources.getString("STARTZumin")%>
                              <br/>
                              <%=myResources.getString("STARTRandomContribution")%>
                              <br/>
                              <small class="text-muted ml-2">
                                  <%= randomCorpusID %> / <%= randomTranscriptID %> / <%= randomAnnotationBlockID %> 
                              </small> 
                              <a href="./jsp/zuMin.jsp?transcriptID=<%= randomTranscriptID %>&annotationBlockID=<%= randomAnnotationBlockID %>" 
                                 class="btn btn-primary float-right mt-3" target="_blank">
                                <%=myResources.getString("STARTZuminTitle")%> (ZuMin)
                              </a>
                          </p>
                        </div>
                      </li>

                      <!-- *************** -->
                      <!-- OTHER VIEWS  -->  
                      <!-- *************** -->
                      <li class="media my-4">
                        <img src="./images/zupass.png" class="mr-3 start" alt="..."  
                             style="width:480px; border: 2px solid gray; border-radius: 5px;">
                        <div class="media-body">
                          <h5 class="mt-0 mb-1">Transcript: Other views (ZuPass &amp; ZuAnn)</h5>
                          <p>
                              ZuPass visualises transcripts in <b>musical score (Partitur)</b> notation. 
                              ZuAnn visualises transcripts with all <b>annotations</b>.
                              The following transcript was chosen at random: <br/>
                              <small class="text-muted ml-2"><%= randomCorpusID %> / <%= randomTranscriptID %> </small> 
                              <a href="./jsp/zuPass.jsp?transcriptID=<%= randomTranscriptID %>" class="btn btn-primary float-right mt-3" target="_blank">
                                Transcript Visualisation with ZuPass
                              </a>
                              <a href="./jsp/zuAnn.jsp?transcriptID=<%= randomTranscriptID %>" class="btn btn-primary float-right mt-3" target="_blank">
                                Transcript Visualisation with ZuAnn
                              </a>
                              <br/>
                          </p>
                        </div>
                      </li>
                      
                      
                    </ul>                    
                </div>
                <div class="col-1"></div>
            </div>
        </div>
                                   
        <footer class="footer mx-5">
            <hr class="mx-12">
            <div class="container text-center">
                <span class="text-muted">This ZuMult installation is provided by</span>
                <a href="https://linguisticbits.de" target="_blank">linguisticbits.de</a>.
                <span class="text-muted">See</span>
                <a target="_blank" href="https://zumult.org">zumult.org</a>
                <span class="text-muted">for more info and news about ZuMult.</span>
                <div class="mt-3">
                    <a class="btn btn-secondary btn-sm" href="./jsp/diagnostics.jsp"><i class="fa-regular fa-display-medical"></i> Go to diagnostics</a>
                </div>
                
            </div>
        </footer>                                   
        
        
        
    </body>
</html>
