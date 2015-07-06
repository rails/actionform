(function($) {

  var createNewResourceID = function() {
    return new Date().getTime();
  }

  $(document).on('click', '.add_fields', function(e) {
    e.preventDefault();

    var $link = $(this);
    var assoc = $link.data('association');
    var content = $link.data('association-insertion-template');
    var insertionMethod = $link.data('association-insertion-method') || $link.data('association-insertion-position') || 'before';
    var insertionNode = $link.data('association-insertion-node');
    var insertionTraversal = $link.data('association-insertion-traversal');
    var newId = createNewResourceID();
    var regex = new RegExp("new_" + assoc, "g");
    var newContent = content.replace(regex, newId);

    if (insertionNode){
      if (insertionTraversal){
        insertionNode = $link[insertionTraversal](insertionNode);
      } else {
        insertionNode = insertionNode == "this" ? $link : $(insertionNode);
      }
    } else {
      insertionNode = $link.parent();
    }

    var contentNode = $(newContent);
    insertionNode.trigger('before-insert', [contentNode]);

    var addedContent = insertionNode[insertionMethod](contentNode);

    insertionNode.trigger('after-insert', [contentNode]);
  });

  $(document).on('click', '.remove_fields.dynamic, .remove_fields.existing', function(e) {
    e.preventDefault();

    var $link = $(this);
    var wrapperClass = $link.data('wrapper-class') || 'nested-fields';
    var nodeToDelete = $link.closest('.' + wrapperClass);
    var triggerNode = nodeToDelete.parent();

    triggerNode.trigger('before-remove', [nodeToDelete]);

    var timeout = triggerNode.data('remove-timeout') || 0;

    setTimeout(function() {
      if ($link.hasClass('dynamic')) {
          nodeToDelete.remove();
      } else {
          $link.prev("input[type=hidden]").val("1");
          nodeToDelete.hide();
      }
      triggerNode.trigger('after-remove', [nodeToDelete]);
    }, timeout);
  });

})(jQuery);
