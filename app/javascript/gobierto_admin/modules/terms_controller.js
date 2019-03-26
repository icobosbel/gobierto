import Sortable from 'sortablejs';

window.GobiertoAdmin.TermsController = (function() {
  function TermsController() {}

  TermsController.prototype.index = function() {
    _handleTermsList();
    _handleSortableList();
  };

  function _handleTermsList() {
    // Toggle selected element child
    $('.v_container .v_el .icon-caret').click(function(e) {
      e.preventDefault();

      // ToDo: Don't relay on icon specific names
      if($(this).is('.fa-caret-right')) {
        $(this).removeClass('fa-caret-right');
        $(this).addClass('fa-caret-down');
      }
      else {
        $(this).removeClass('fa-caret-down');
        $(this).addClass('fa-caret-right');
      }

      $(this).parent().parent().parent().parent().find('> .list-group > .v_el').toggleClass('el-opened');

    });

    // Close all elements except first level
    $('.v_container .v_heading .fa-caret-square-right').click(function(e) {
      // closes all elements
      $('.v_container .v_el_level .v_el').removeClass('el-opened');
    });

    // Open all elements except first level
    $('.v_container .v_heading .fa-caret-square-down').click(function(e) {
      // Opens all elements
      $('.v_container .v_el_level .v_el').addClass('el-opened');
    });

    // show only action buttons (edit, delete) when hovering an item
    // ToDo: Control that only elements for the item are shown, not for it's parents
    $('.v_el').hover(
      function(e) {
        $(this).first('.v_el_actions').addClass('v_el_active');
      },
      function(e) {
        $(this).first('.v_el_actions').removeClass('v_el_active');
      }
    );
  }

  function _handleSortableList() {
    var nestedSortables = [].slice.call(document.querySelectorAll('.list-group'));

    // Loop through each nested sortable element
    for (let i = 0; i < nestedSortables.length; i++) {
      Sortable.create(nestedSortables[i], {
        group: "nested",
        animation: 150,
        fallbackOnBody: true,
        swapThreshold: 0.65,
      });
    }

    // $(wrapper).sortable({
    //   items: 'div.v_el',
    //   handle: '.custom_handle',
    //   forcePlaceholderSize: true,
    //   placeholder: '<div class="v_el v_el_level"></div>',
    //   update: function() {
    //     _refreshPositions(wrapper);
    //     _requestUpdate(wrapper, _buildPositions(wrapper));
    //   }
    // });
  }

  function _refreshPositions(wrapper) {
    $(wrapper).find("div.v_el").each(function(index) {
      $(this).attr("data-pos", index + 1);
    });
  }

  function _buildPositions(wrapper) {
    var positions = [];

    $(wrapper).find("div.v_el").each(function(index) {
      positions.push({
        id: $(this).data("id"),
        position: index + 1
      });
    });

    return positions;
  }

  function _requestUpdate(wrapper, positions) {
    $.ajax({
      url: $(wrapper).data("sortable-target"),
      method: "POST",
      data: { positions: positions }
    });
  }

  return TermsController;
})();

window.GobiertoAdmin.terms_controller = new GobiertoAdmin.TermsController;
