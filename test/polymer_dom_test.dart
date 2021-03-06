// firefox and safari fail at this moment
// for some reason context['Polymer'] is null
@TestOn('browser')
library polymer_interop.polymerdom_test;

import 'dart:html';

import 'package:test/test.dart';
import 'package:polymer_interop/polymer_interop.dart';
import 'package:web_components/web_components.dart';

main() async {
  await initWebComponents();

  CustomElement node = querySelector('.test-element');
  PolymerDom domApi = Polymer.dom(node);
  DivElement parent = querySelector('#parent');
  SpanElement child = new SpanElement()..text = 'My span.';
  SpanElement beforeNode = new SpanElement()..text = 'Before Node. ';

  group('PolmyerDom', () {
    test('field node', () {
      expect(domApi.node, node);
    });

    test('active element', () {
      PolymerDom rootApi = new PolymerDom(node.root);
      ButtonElement btn = rootApi.querySelector("#myButton");
      btn.focus();
      expect(rootApi.activeElement,btn);
      expect(new PolymerDom(document).activeElement, node);
    });

    test('method append',
        () => expect(domApi.append(child), new isInstanceOf<SpanElement>()));

    test('getter childNodes', () => expect(domApi.childNodes, [child]));

    test('getter children', () => expect(domApi.children, [child]));

    test('getter classList', () {
      expect(domApi.classList, new isInstanceOf<PolymerClassList>());
    });

    test('method deepContains', () {
      // Self
      expect(domApi.deepContains(node), isTrue);

      // Local Dom
      var button = node.$['myButton'];
      expect(button, isNotNull);
      expect(new PolymerDom(parent).deepContains(button), isTrue);
      expect(domApi.deepContains(button), isTrue);

      // Sanity check
      var newNode = new DivElement();
      expect(domApi.deepContains(newNode), isFalse);
    });

    test('getter lastChild', () {
      expect(domApi.lastChild, child);
    });

    test('getter lastElementChild', () {
      expect(domApi.lastElementChild, child);
    });

    test('method flush', () {
      expect(PolymerDom.flush(), null);
    });

    test('method getDestinationInsertionPoints', () {
      expect(domApi.getDestinationInsertionPoints(),
          new isInstanceOf<List<Node>>());
    });

    test('method getDistributedNodes', () {
      expect(domApi.getDistributedNodes(), new isInstanceOf<List<Node>>());
    });

    // add the custom-element is not contained in another custom-element, this
    // should return null
    test('method getOwnerRoot', () {
      expect(domApi.getOwnerRoot(), null);
    });

    test('getter innerHTML', () {
      expect(domApi.innerHtml, '<span>My span.</span>');
    });

    test('setter innerHTML', () {
      domApi.innerHtml = '<span>My span updated.</span>';
      expect(domApi.innerHtml, '<span>My span updated.</span>');
    });

    test('method insertBefore', () {
      expect(domApi.insertBefore(beforeNode, domApi.firstChild), beforeNode);
    });

    test('getter firstChild', () {
      expect(domApi.firstChild, beforeNode);
    });

    test('getter firstElementChild', () {
      expect(domApi.firstElementChild, beforeNode);
    });

    test('getter nextElementSibling', () {
      expect(domApi.nextElementSibling, querySelector('#next-element'));
    });

    test('getter nextSibling', () {
      expect(domApi.nextSibling, new isInstanceOf<Text>());
    });

    test('getter parentNode', () {
      expect(domApi.parentNode, parent);
    });

    test('getter previousElementSibling', () {
      expect(domApi.previousElementSibling, querySelector('#previous-element'));
    });

    test('getter previousSibling', () {
      expect(domApi.previousSibling, new isInstanceOf<Text>());
    });

    test('method queryDistributedElements', () {
      expect(domApi.queryDistributedElements('span'),
          new isInstanceOf<List<Node>>());
    });

    test('method querySelector', () {
      expect(domApi.querySelector('span'), new isInstanceOf<SpanElement>());
    });

    test('method querySelectorAll', () {
      expect(domApi.querySelectorAll('span'), new isInstanceOf<List<Node>>());
    });

    test('method replaceChild', () {
      var span = new SpanElement()..text = 'Before Node updated. ';
      expect(domApi.replaceChild(span, domApi.firstElementChild), span);
    });

    test('method removeChild', () {
      var child = domApi.firstElementChild;
      expect(domApi.removeChild(child), child);
    });

    test('method setAttribute', () {
      expect(domApi.setAttribute('role', 'note'), null);
      expect(node.getAttribute('role'), 'note');
    });

    test('method removeAttribute', () {
      expect(domApi.removeAttribute('role'), null);
      expect(node.getAttribute('role'), null);
    });

    test('getter text', () {
      expect(domApi.text, 'My span updated.');
    });

    test('setter text', () {
      domApi.text = 'My span.';
      expect(domApi.text, 'My span.');
      domApi.text = '';
    });

    test('observeNodes', () async {
      var mutations = <PolymerDomMutation>[];
      var handle = domApi.observeNodes((mutation) {
        mutations.add(mutation);
      });
      var div = new DivElement();
      domApi.append(div);
      PolymerDom.flush();
      expect(mutations.length, 1);
      expect(mutations[0].addedNodes, [div]);

      domApi.removeChild(div);
      PolymerDom.flush();
      expect(mutations.length, 2);
      expect(mutations[1].removedNodes, [div]);

      domApi.unobserveNodes(handle);
    });

    test('unobserveNodes', () async {
      var mutations = <PolymerDomMutation>[];
      var handle = domApi.observeNodes((mutation) {
        mutations.add(mutation);
      });

      var div = new DivElement();
      domApi.append(div);
      PolymerDom.flush();
      expect(mutations.length, 1);

      domApi.unobserveNodes(handle);
      domApi.removeChild(div);
      PolymerDom.flush();
      expect(mutations.length, 1);
    });

    group('PolymerClassList', () {
      Element element;
      PolymerClassList classList;

      setUp(() {
        element = domApi.node;
        classList = domApi.classList;
      });

      test('add', () {
        classList.add('test');
        expect(element.classes.contains('test'), true);
        classList.add('test2');
        expect(element.classes.contains('test'), true);
        expect(element.classes.contains('test2'), true);
      });

      test('addAll', () {
        classList.addAll(['test3', 'test4']);
        expect(element.classes.contains('test'), true);
        expect(element.classes.contains('test2'), true);
        expect(element.classes.contains('test3'), true);
        expect(element.classes.contains('test4'), true);
      });

      test('remove', () {
        classList.remove('test2');
        expect(element.classes.contains('test'), true);
        expect(element.classes.contains('test2'), false);
        expect(element.classes.contains('test3'), true);
        expect(element.classes.contains('test4'), true);
        classList.remove('test');
        expect(element.classes.contains('test'), false);
      });

      test('removeAll', () {
        classList.removeAll(['test', 'test2', 'test3']);
        expect(element.classes.contains('test'), false);
        expect(element.classes.contains('test2'), false);
        expect(element.classes.contains('test3'), false);
        expect(element.classes.contains('test4'), true);
      });

      test('toggle', () {
        classList.toggle('class1');
        expect(element.classes.contains('class1'), true);
        classList.toggle('class1', true);
        expect(element.classes.contains('class1'), true);
        classList.toggle('class1');
        expect(element.classes.contains('class1'), false);
        classList.toggle('class1', false);
        expect(element.classes.contains('class1'), false);
      });
    });
  });

  group('PolymerEvent', () {
    var button;

    setUp(() {
      button = node.$['myButton'];
    });

    void testEvent(event) {
      event = Polymer.dom(event) as PolymerEvent;
      expect(event.localTarget, node);
      expect(event.rootTarget, button);
      expect(event.path, [
        button,
        node.$['wrapper'],
        node.root,
        node,
        parent,
        document.body,
        document.documentElement,
        document,
        window,
      ]);
    }

    test('basic', () {
      var done = document.body.on['click'].first.then((event) {
        testEvent(event);
      });

      button.click();
      return done;
    });

    test('works with CustomEventWrapper objects', () {
      var button = node.$['myButton'];

      var done = document.body.on['hello'].first.then((event) {
        testEvent(new CustomEventWrapper(event));
      });

      button.dispatchEvent(new CustomEvent('hello', detail: 'world'));
      return done;
    });
  });
}

@CustomElementProxy('custom-element')
class CustomElement extends HtmlElement
    with PolymerBase, CustomElementProxyMixin {
  CustomElement.created() : super.created();
}
