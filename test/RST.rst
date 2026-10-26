==========
Main title
==========

Section
=======

Subsection
----------

Paragraph with *emphasis*, **strong emphasis**, ``inline literal``,
`interpreted text`, :code:`role text`, and a link_ to somewhere.
Also an `inline link <https://example.com>`_ and an anonymous one__.

.. _link: https://example.com
__ https://example.org

Footnote reference [1]_ and a citation [CIT2002]_.

.. [1] The footnote.
.. [CIT2002] The citation.

.. This is a comment
   that spans multiple lines.

Lists
-----

- Bullet item
- Another item

  * Nested item

1. Numbered item
2. Second item

#. Auto-numbered item

term
   Definition of the term.

:field: Field list value
:another field: Another value

Code
----

A literal block follows::

    def hello():
        return "world"

.. code-block:: python

   def add(a, b):
       return a + b

>>> print("doctest")
doctest

Directives
----------

.. note::

   This is a note.

.. image:: /assets/icon.png
   :alt: Icon
   :width: 100px

.. |name| replace:: substitution text

Text with a |name| substitution.

Tables
------

=====  =====  ======
A      B      A or B
=====  =====  ======
False  False  False
True   False  True
=====  =====  ======

+------------+------------+
| Header 1   | Header 2   |
+============+============+
| Cell 1     | Cell 2     |
+------------+------------+

| Line block
| keeps line breaks

    Block quote text.

    -- Attribution

----

Transition above.

Sphinx
======

Roles
-----

See :ref:`installation`, :ref:`the install guide <installation>`,
and :doc:`/usage/quickstart` or :doc:`Quickstart <usage/quickstart>`.

Python objects: :mod:`os.path`, :class:`collections.OrderedDict`,
:func:`json.dumps`, :meth:`str.join`, :attr:`Foo.bar`, :exc:`ValueError`,
:data:`sys.argv`, :const:`math.pi`, :obj:`None`, :py:func:`print`.

Short names: :class:`~collections.OrderedDict`, no link: :func:`!private`.

Other domains: :c:func:`malloc`, :cpp:class:`std::vector`, :js:func:`fetch`.

Misc roles: :term:`glossary term`, :envvar:`PATH`, :option:`--verbose`,
:download:`script <files/script.py>`, :abbr:`RST (reStructuredText)`,
:kbd:`Ctrl+C`, :guilabel:`&Cancel`, :file:`/etc/{name}.conf`,
:samp:`print({value})`, :command:`make`, :program:`sphinx-build`,
:math:`a^2 + b^2 = c^2`, :pep:`8`, :rfc:`2324`, :code:`x = 1`.

Table of contents
-----------------

.. toctree::
   :maxdepth: 2
   :caption: Contents:
   :hidden:

   installation
   usage/quickstart
   Custom title <api/index>

Autodoc
-------

.. currentmodule:: mypackage

.. automodule:: mypackage.module
   :members:
   :undoc-members:
   :show-inheritance:

.. autoclass:: mypackage.module.MyClass
   :members: method_one, method_two
   :special-members: __init__
   :exclude-members: private_method

   .. automethod:: extra_method

.. autofunction:: mypackage.module.helper

.. autoexception:: mypackage.errors.CustomError

.. autodata:: mypackage.module.CONSTANT
   :annotation: = 42

Python domain
-------------

.. py:module:: mypackage.shapes

.. py:class:: Circle(radius)

   A circle shape.

   :param radius: The circle radius.
   :type radius: float
   :raises ValueError: If ``radius`` is negative.

   .. py:method:: area()

      Returns the area.

      :returns: The area of the circle.
      :rtype: float

   .. py:attribute:: radius
      :type: float

.. py:function:: create(kind: str, *args, **kwargs) -> Shape
   :async:

   Creates a shape.

.. function:: legacy_style(arg1, arg2=None)

   :param arg1: First argument.
   :param int arg2: Second argument, with an inline type.

.. data:: DEFAULT_RADIUS

   Default radius value.

Admonitions and versions
------------------------

.. warning::

   Be careful.

.. seealso::

   :func:`json.loads`
      The opposite operation.

.. versionadded:: 2.0
   The ``kind`` argument.

.. versionchanged:: 2.1
   Now supports :class:`Square`.

.. deprecated:: 3.0
   Use :func:`create` instead.

.. admonition:: Custom title
   :class: tip

   Custom admonition body.

Code
----

.. highlight:: python

.. literalinclude:: ../examples/example.py
   :language: python
   :lines: 1-10
   :emphasize-lines: 3,5
   :caption: example.py

.. code-block:: console

   $ pip install mypackage

.. code-block:: javascript
   :linenos:

   const x = 1;

.. doctest::

   >>> 1 + 1
   2

.. testcode::

   print("hello")

.. testoutput::

   hello

Other directives
----------------

.. glossary::

   glossary term
      A term defined in the glossary.

.. math::

   e^{i\pi} + 1 = 0

.. index::
   single: shapes; circle
   pair: shape; area

.. only:: html

   Only in HTML output.

.. _installation:

Installation
------------

Labels like ``.. _installation:`` are targets for :ref:`installation`.
