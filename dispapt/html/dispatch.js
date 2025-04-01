$(document).ready(function() {
    console.log('Dispatch UI Loaded');
    // Force hide UI on load
    $('#dispatch-container').hide();
});

window.addEventListener('message', function(event) {
    const data = event.data;
    console.log('Dispatch UI received message:', data);
    
    if (data.type === 'toggleDispatch') {
        console.log('Toggling dispatch UI:', data.show ? 'show' : 'hide');
        if (data.show) {
            $('#dispatch-container').stop().fadeIn(200);
            // Apply theme styling if specified
            if (data.style) {
                // Remove all existing theme classes
                $('#dispatch-container').removeClass(function (index, className) {
                    return (className.match(/(^|\s)-theme\S+/g) || []).join(' ');
                });
                // Add new theme class
                $('#dispatch-container').addClass(data.style + '-theme');
                
                // Apply theme colors
                const style = Config.Styles[data.style];
                if (style) {
                    $('#dispatch-container').css({
                        '--header-color': style.header,
                        '--text-color': style.text,
                        '--border-color': style.border,
                        '--button-color': style.button,
                        '--button-hover-color': style.buttonHover
                    });
                }
            }
            // Update title if specified
            if (data.title) {
                $('#dispatch-container .header h1').text(data.title);
            } else {
                $('#dispatch-container .header h1').text('Unit Stats');
            }
        } else {
            $('#dispatch-container').stop().fadeOut(200);
            // Clear data when hiding
            $('#current-street').text('Unknown');
            $('#current-area').text('Unknown Area');
            $('#wp-requests').empty();
            $('#active-waypoint').text('None');
            // Remove theme classes and reset CSS variables
            $('#dispatch-container').removeClass(function (index, className) {
                return (className.match(/(^|\s)-theme\S+/g) || []).join(' ');
            });
            $('#dispatch-container').css({
                '--header-color': '',
                '--text-color': '',
                '--border-color': '',
                '--button-color': '',
                '--button-hover-color': ''
            });
            $('#dispatch-container .header h1').text('Unit Stats');
        }
    }
    else if (data.type === 'updateLocation' && $('#dispatch-container').is(':visible')) {
        console.log('Updating location:', data.street, data.area);
        $('#current-street').text(data.street);
        $('#current-area').text(data.area);
    }
    else if (data.type === 'addWaypointRequest' && $('#dispatch-container').is(':visible')) {
        console.log('Adding waypoint request from:', data.name);
        addWaypointRequest(data.id, data.name);
    }
    else if (data.type === 'removeWaypointRequest' && $('#dispatch-container').is(':visible')) {
        console.log('Removing waypoint request:', data.id);
        removeWaypointRequest(data.id);
    }
    else if (data.type === 'updateActiveWaypoint' && $('#dispatch-container').is(':visible')) {
        console.log('Updating active waypoint:', data.name || 'None');
        updateActiveWaypoint(data.name || 'None');
    }
});

function addWaypointRequest(id, name) {
    const request = $('<div class="wp-request">')
        .attr('data-id', id)
        .html(`
            <span>${name} requested location</span>
            <button class="accept">Accept</button>
        `);
    
    request.find('.accept').on('click', function() {
        $.post('https://dispapt/acceptWaypoint', JSON.stringify({
            id: id
        }));
        removeWaypointRequest(id);
    });

    $('#wp-requests').append(request);
}

function removeWaypointRequest(id) {
    $(`.wp-request[data-id="${id}"]`).remove();
}

function updateActiveWaypoint(name) {
    $('#active-waypoint').text(name);
} 