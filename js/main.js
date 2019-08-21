// Generated by CoffeeScript 1.10.0
(function() {
  var $blocks, $filter_links, $initial, all, and_or, any, args, blur_unblur, callNow, categories, context, debounce, mobile, parse_query_string, remove_links, result, switch_link, timeout, timestamp, toggle_blur_active,
    indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

  $filter_links = null;

  $blocks = null;

  $initial = true;

  categories = {};

  toggle_blur_active = function(obj, to_add, to_remove) {
    obj.removeClass(to_remove);
    if (!obj.hasClass(to_add)) {
      return obj.addClass(to_add);
    }
  };

  and_or = function(is_and) {
    $blocks.each(function(index) {
      var key, matching_cats, val;
      matching_cats = (function() {
        var results;
        results = [];
        for (key in categories) {
          val = categories[key];
          if (val) {
            results.push($(this).hasClass(key));
          }
        }
        return results;
      }).call(this);
      if ((is_and && all(matching_cats)) || (!is_and && any(matching_cats))) {
        toggle_blur_active($(this), 'active', 'blur');
      } else {
        toggle_blur_active($(this), 'blur', 'active');
      }
      return true;
    });
    return true;
  };

  debounce = function(func, wait, immediate) {
    var later;
    if (immediate == null) {
      immediate = false;
    }
    later = function() {
      var args, context, last, result, timeout;
      last = $.now() - timestamp;
      if (last < wait && last >= 0) {
        return timeout = setTimeout(later, wait - last);
      } else {
        timeout = null;
        if (!immediate) {
          result = func.apply(context, args);
          if (!timeout) {
            return context = args = null;
          }
        }
      }
    };
    return function() {};
  };

  context = this;

  args = arguments;

  timestamp = $.now();

  callNow = immediate && !timeout;

  if (!timeout) {
    timeout = setTimeout(later, wait);
  }

  if (callNow) {
    result = func.apply(context, args);
    context = args = null;
  }

  return result;

  any = function(array) {
    return indexOf.call(array, true) >= 0;
  };

  all = function(array) {
    return indexOf.call(array, false) < 0;
  };

  mobile = function(size) {
    var switch_and_or;
    return size < (switch_and_or = function() {
      $('#or').toggleClass('active');
      $('#and').toggleClass('active');
      return blur_unblur();
    });
  };

  blur_unblur = function() {
    var any_selected, key, val;
    any_selected = any((function() {
      var results;
      results = [];
      for (key in categories) {
        val = categories[key];
        results.push(val);
      }
      return results;
    })());
    if (any_selected) {
      return and_or($('#and').hasClass('active'));
    } else {
      $blocks.removeClass('blur');
      return $blocks.removeClass('active');
    }
  };

  switch_link = function(obj, category_name) {
    obj.toggleClass('active');
    categories[category_name] = obj.hasClass('active');
    return blur_unblur();
  };

  remove_links = function() {
    $blocks = $('.block');
    $('.block a').attr('href', '');
    $filter_links = $("#categories li a");
    return $filter_links.removeAttr('href');
  };

  parse_query_string = function() {
    var cat, category_keys, category_name, i, len, query, requested, results;
    category_keys = [];
    $('#categories li').each(function(index) {
      var category;
      category = $(this).text().substring(2);
      categories[category] = false;
      category_keys.push(category);
      return true;
    });
    query = window.location.search.substring(1);
    if (!query.length) {
      query = window.location.href.split("/filter/");
      query = query.length > 1 ? query[0] : void 0;
    }
    if ((query.indexOf("-")) !== -1) {
      requested = (function() {
        var i, len, ref, ref1, results;
        ref = query.split('-');
        results = [];
        for (i = 0, len = ref.length; i < len; i++) {
          cat = ref[i];
          if (ref1 = cat.toLowerCase(), indexOf.call(category_keys, ref1) >= 0) {
            results.push(cat);
          }
        }
        return results;
      })();
    } else if ((query.indexOf("+")) !== -1) {
      switch_and_or();
      requested = (function() {
        var i, len, ref, ref1, results;
        ref = query.split('+');
        results = [];
        for (i = 0, len = ref.length; i < len; i++) {
          cat = ref[i];
          if (ref1 = cat.toLowerCase(), indexOf.call(category_keys, ref1) >= 0) {
            results.push(cat);
          }
        }
        return results;
      })();
    } else {
      requested = indexOf.call(category_keys, query) >= 0 ? [query] : [];
    }
    results = [];
    for (i = 0, len = requested.length; i < len; i++) {
      category_name = requested[i];
      results.push(switch_link($('#' + category_name), category_name));
    }
    return results;
  };

  $(window).resize(function() {});

  $('.block').click(function() {
    return $('.ajax', this).stop(true, true).slideDown('normal').addClass('open');
  });

  $('#and').click(function() {
    return switch_and_or();
  });

  $('#or').click(function() {
    return switch_and_or();
  });

  $("#categories li a").click(function() {
    return switch_link($(this).parent(), $(this).text().substring(2));
  });

  $(function() {
    remove_links();
    return parse_query_string();
  });

}).call(this);