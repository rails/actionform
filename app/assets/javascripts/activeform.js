(function($) {
  // Form API, draft version:
  // $(".task_list").addFormField("tasks")
  // $(".task_list").removeFormField("tasks", 2) // destroy second field

  var activeFormHelpers = {
    generateResourceId: function() {
      return new Date().getTime();
    }
  };

  $.fn.removeFormField = function(nodeToDeleteOrIndex, options) {
    if(options == undefined) {
      options = {}
    }

    var nodeToDelete;

    if(nodeToDeleteOrIndex instanceof jQuery) {
      nodeToDelete = nodeToDeleteOrIndex;
    } else {
      var wrapperClass = this.data('wrapper-class') || 'nested-fields';
      console.log(wrapperClass)
      nodeToDelete = this.find("." + wrapperClass).filter(function(i, b) {
        return $(b).css('display') != 'none';
      }).eq(nodeToDeleteOrIndex);
    }

    this.trigger('before-remove', [nodeToDelete]);

    var timeout = this.data('remove-timeout') || 0;

    var input = nodeToDelete.find("input").filter(function(i, t) {
      return false
    })

    var isDynamic = nodeToDelete.hasClass("dynamic");

    var context = this;
    setTimeout(function() {
      if (isDynamic) {
          nodeToDelete.remove();
      } else {
          nodeToDelete.find("input[type=hidden]").val("1");
          nodeToDelete.hide();
      }
      context.trigger('after-remove', [nodeToDelete]);
    }, timeout);

    return this
  };

  $.fn.addFormField = function(assoc, options) {
    if(options == undefined) {
      options = {}
    }
    var templateSelector = "." + assoc + "_template";

    var templateContainer;
    $(this).parents().each(function(i, el){
      var found = $(el).find(templateSelector)
      if(found.length > 0) {
        templateContainer = found.eq(0)
        return false;
      }
    })

    var newId = activeFormHelpers.generateResourceId();
    var regex = new RegExp("new_" + assoc, "g");
    var content = templateContainer.html().replace(regex, newId);
    var contentNode = $(content);

    contentNode.addClass("dynamic")

    if(!options.insertionMethod) {
      options.insertionMethod = 'append';
    }

    this.trigger('before-insert', [contentNode]);

    var addedContent = this[options.insertionMethod](contentNode);

    this.trigger('after-insert', [contentNode]);

    return this;
  };

  $(document).on('click', '.add_fields', function(e) {
    e.preventDefault();

    var $link = $(this);
    var form = $link.parents("form").eq(0);
    var assoc = $link.data('association');
    var insertionMethod = $link.data('association-insertion-method') || $link.data('association-insertion-position');
    var insertionNode = $link.data('association-insertion-node');
    var insertionTraversal = $link.data('association-insertion-traversal');

    if (insertionNode){
      if (insertionTraversal){
        insertionNode = $link[insertionTraversal](insertionNode);
      } else {
        if(insertionNode == "this") {
          insertionNode = $(this)
        } else {
          $(this).parents().each(function(i, el){
            var found = $(el).find(insertionNode)
            if(found.length > 0) {
              insertionNode = found.eq(0)
              return false;
            }
          })
        }
      }
    } else {
      insertionNode = $link.parent();
    }

    insertionNode.addFormField(assoc, {
      insertionMethod: insertionMethod,
      insertionTraversal: insertionTraversal,
    })
  });

  $(document).on('click', '.remove_fields, .remove_fields', function(e) {
    e.preventDefault();

    var $link = $(this);
    var wrapperClass = $link.data('wrapper-class') || 'nested-fields';
    var nodeToDelete = $link.closest('.' + wrapperClass);

    var triggerNode = nodeToDelete.parent();

    triggerNode.removeFormField(nodeToDelete)
  });

})(jQuery);
