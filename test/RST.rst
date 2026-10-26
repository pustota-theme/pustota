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
