define(['Handlebars'], function(Handlebars){
	return function(context, option) {
		var field, items, ret;

		ret = '';
		items = (function() {
		  var _results;

		  _results = [];
		  for (field in context) {
		    _results.push(options.fn(context[field]));
		  }
		  return _results;
		})();
		return items.join('');
	}
})
