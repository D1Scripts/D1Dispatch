$(document).ready(function() {
    console.log('Radio UI Loaded');
});

window.addEventListener('message', function(event) {
    const data = event.data;
    
    if (data.type === 'toggleDisplay') {
        if (data.show) {
            $('#radio-container').fadeIn(200);
            if (data.title) {
                $('#radio-container .header h1').text(data.title);
            }
        } else {
            $('#radio-container').fadeOut(200);
            $('#radio-container .header h1').text('Radio');
        }
    }
    else if (data.type === 'toggleDispatch') {
        if (data.show) {
            $('#dispatch-container').fadeIn(200);
            if (data.title) {
                $('#dispatch-container .header h1').text(data.title);
            }
            if (data.style) {
                // Remove any existing style classes
                $('#dispatch-container').removeClass('sast-style safr-style alonzo-style vagos-style ballas-style families-style');
                // Add the new style class
                $('#dispatch-container').addClass(data.style);
            }
        } else {
            $('#dispatch-container').fadeOut(200);
            $('#dispatch-container .header h1').text('Dispatch');
        }
    }
    else if (data.type === 'updateChannel') {
        $('#channel-number').text(data.channel);
        $('#member-count').text(data.count);
        if (data.title) {
            $('#radio-container .header h1').text(data.title);
        }
        if (data.style) {
            // Remove any existing style classes
            $('#radio-container').removeClass('sast-style safr-style alonzo-style vagos-style ballas-style families-style');
            // Add the new style class
            $('#radio-container').addClass(data.style);
        }
    }
    else if (data.type === 'updateMembers') {
        updateMembersList(data.members);
    }
});

function updateMembersList(members) {
    const membersList = $('#members-list');
    membersList.empty();

    if (!Array.isArray(members)) {
        console.error('Members is not an array:', members);
        return;
    }

    members.forEach(function(member) {
        const memberElement = $('<div class="member">')
            .text(member.name)
            .attr('data-id', member.id);

        if (member.talking) {
            memberElement.addClass('talking');
        }

        membersList.append(memberElement);
    });
} 