package com.lookout.leafy.metrics;

import org.jruby.runtime.builtin.IRubyObject;
import org.jruby.Ruby;
import org.jruby.RubyString;
import org.jruby.*;

import com.codahale.metrics.Meter;

public class AllocateMetricsObjectSpacer implements Ruby.ObjectSpacer {

    public final Meter string = new Meter();
    public final Meter symbol = new Meter();
    public final Meter fixnum = new Meter();
    public final Meter array = new Meter();
    public final Meter hash = new Meter();
    public final Meter total = new Meter();

    public void addToObjectSpace(Ruby runtime, boolean useObjectSpace, IRubyObject object) {
	switch(object.getClass().getSimpleName()) {
	case "RubyString": string.mark();break;
        case "RubySymbol": symbol.mark(); break;
        case "RubyFixnum": fixnum.mark(); break;
        case "RubyArray": array.mark(); break;
        case "RubyHash": hash.mark(); break;
        default:
	}
	total.mark();
    }
}
