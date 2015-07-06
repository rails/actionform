$(document).ready(function() {
    $("#owner a.add_fields").
      data("association-insertion-position", 'before').
      data("association-insertion-node", 'this');

    $('#owner').bind('after-insert',
         function() {
           $("#owner_from_list").hide();
           $("#owner a.add_fields").hide();
         });
    $('#owner').bind("after-remove",
         function() {
           $("#owner_from_list").show();
           $("#owner a.add_fields").show();
         });

    $("#tags a.add_fields").
      data("association-insertion-position", 'before').
      data("association-insertion-node", 'this');

    $('#tags').bind('after-insert',
         function(e, tag) {
             $(".project-tag-fields a.add_fields").
                 data("association-insertion-position", 'before').
                 data("association-insertion-node", 'this');
             $('.project-tag-fields').bind('after-insert',
                  function() {
                    $(this).children("#tag_from_list").remove();
                    $(this).children("a.add_fields").hide();
                  });
         });

    $('#tasks').bind('before-insert', function(e,task_to_be_added) {
        task_to_be_added.fadeIn('slow');
    });

    $('#tasks').bind('after-insert', function(e, added_task) {
        //added_task.css("background","red");
    });

    $('#tasks').bind('before-remove', function(e, task) {
        $(this).data('remove-timeout', 1000);
        task.fadeOut('slow');
    })

    $('body').tabs();
});