/* 
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/JavaScript.js to edit this template
 */

// open ZuViel with the transcript in line notation
function openLineTranscript(transcriptID){
    let url = "./zuViel.jsp?transcriptID=" + transcriptID;
    window.open(url, '_blank');    
}

function openScoreTranscript(transcriptID){
    let url = "./zuPass.jsp?transcriptID=" + transcriptID;
    window.open(url, '_blank');    
}

function playAudio(audioID, element){
    let randomID = 'id-' + Date.now() + '-' + Math.random().toString(36).substr(2, 5);
    $.post(
        BASE_URL + "/ZumultDataServlet",
        { 
            command: 'getAudio',
            audioID: audioID
        },
        function( data ) {
            let audioURL = $(data).find("audio").first().text();
            if (audioURL.length === 0){
                alert('No audio for ' + transcriptID);                            
            } else {
                let audioHTML = "<audio type=\"audio/mp3\" src=\"" + audioURL + "\" id=\"" + randomID + "\"></audio>";
                let pauseHTML = "<i class=\"fa-solid fa-pause\"></i>";
                $(element).html(audioHTML + pauseHTML);
                const audio = $('#' + randomID)[0];
                // Check if the audio is ready to play
                if (audio.readyState >= 2) { // 2 = HAVE_CURRENT_DATA
                    audio.play(); // Start playing
                } else {
                    // If the audio is not ready, wait until it is loaded
                    audio.addEventListener('canplay', function onCanPlay() {
                    audio.play(); // Start playing
                    audio.removeEventListener('canplay', onCanPlay); // Remove the event listener
                    });
                }  
                element.onclick = function(){
                    stopAudio(this, randomID, audioID);
                };                                
            }
        }
    );                        

}

function stopAudio(parent, elementID, audioID){
    const audio = $('#' + elementID)[0];
    audio.pause();
    let playHTML = "<i class=\"fa-solid fa-play\"></i>";
    $(parent).html(playHTML);
    parent.onclick = function(){
        playAudio(audioID, this);
    };                
}

function playVideo(videoID){
    $.post(
        BASE_URL + "/ZumultDataServlet",
        { 
            command: 'getVideo',
            videoID: videoID
        },
        function( data ) {
            let time = 0.0;
            let videoURL = $(data).find("video").first().text();
            if (videoURL.length === 0){
                alert('No video found with ID ' + videoID);                            
            } else {
                insertVideoPlayer(videoURL, Math.max(0.0, time - 1.0));
            }
        }
    );                    

}

function insertVideoPlayer(videoURL, time){
    let videoHTML = "<video id=\"modal-video\" controls=\"controls\" type=\"video/mp4\" src=\"" + videoURL +  "\"></video>";
    $('#video-div').html(videoHTML);                
    const video = $('#modal-video')[0];
    // Check if the video is ready to play
    if (video.readyState >= 2) { // 2 = HAVE_CURRENT_DATA
        video.currentTime = time; // Set the playback position
        video.play(); // Start playing
    } else {
        // If the audio is not ready, wait until it is loaded
        video.addEventListener('canplay', function onCanPlay() {
            video.currentTime = time; // Set the playback position
            video.play(); // Start playing
            video.removeEventListener('canplay', onCanPlay); // Remove the event listener
        });
    }  
    $('#videoModal').modal("toggle");
}

function stopVideo(){
    const video = $('#modal-video')[0];
    video.pause();
    video.remove();
}


// ********************************
function showSpeechEvents(speakerID){
    $.post(
        BASE_URL + "/ZumultDataServlet",
        { 
            command: 'getSpeechEventMetadata',
            format: 'html',
            speakerID : speakerID
        },
        function( data ) {
            $("#metadata-body").html(data);
            $("#metadata-title").html("<i class=\"fa-solid fa-comment-dots\" aria-hidden=\"true\"></i> " + speakerID);
            $('#metadataModal').modal("toggle");
        }
    );                                                    
}


// ********************************
function openSpeechEventMetadata(speechEventID){
    $.post(
        BASE_URL + "/ZumultDataServlet",
        { 
            command: 'getEventHTML',
            speechEventID : speechEventID
        },
        function( data ) {
            $("#metadata-body").html(data);
            $("#metadata-title").html(speechEventID);
            $('#metadataModal').modal("toggle");
        }
    );                                    
}


// ********************************
function showSpeakers(speechEventID){
    $.post(
        BASE_URL + "/ZumultDataServlet",
        { 
            command: 'getSpeakerMetadata',
            format: 'html',
            speechEventID : speechEventID
        },
        function( data ) {
            $("#metadata-body").html(data);
            $("#metadata-title").html("<i class=\"fa-solid fa-comment-dots\" aria-hidden=\"true\"></i> " + speechEventID);
            $('#metadataModal').modal("toggle");
        }
    );                                                    
}

// ********************************
function openSpeakerMetadata(speakerID){
    $.post(
        BASE_URL + "/ZumultDataServlet",
        { 
            command: 'getSpeakerMetadata',
            speakerID : speakerID
        },
        function( data ) {
            $("#metadata-body").html(data);
            $("#metadata-title").html(speakerID);
            $('#metadataModal').modal("toggle");
        }
    );                                    
}

// ********************************

function showSpeechEvents(speakerID){
    $.post(
        BASE_URL + "/ZumultDataServlet",
        { 
            command: 'getSpeechEventMetadata',
            format: 'html',
            speakerID : speakerID
        },
        function( data ) {
            $("#metadata-body").html(data);
            $("#metadata-title").html("<i class=\"fa-solid fa-comment-dots\" aria-hidden=\"true\"></i> " + speakerID);
            $('#metadataModal').modal("toggle");
        }
    );                                                    
}

// ********************************
function openMediaMetadata(mediaID){
    $.post(
        BASE_URL + "/ZumultDataServlet",
        { 
            command: 'getMediaMetadata',
            mediaID : mediaID
        },
        function( data ) {
            $("#metadata-body").html(data);
            $("#metadata-title").html(mediaID);
            $('#metadataModal').modal("toggle");
        }
    );                                    
}


// ********************************
function openTranscriptMetadata(transcriptID){
    $.post(
        BASE_URL + "/ZumultDataServlet",
        { 
            command: 'getTranscriptMetadata',
            transcriptID : transcriptID
        },
        function( data ) {
            $("#metadata-body").html(data);
            $("#metadata-title").html(transcriptID);
            $('#metadataModal').modal("toggle");
        }
    );                                    
}



