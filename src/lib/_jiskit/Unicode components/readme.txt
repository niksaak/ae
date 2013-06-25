для нормального использования нужно учесть следующе моменты: TTableListViewW - это надстройка над обычным ListView, там есть несколько костылей, которые оказалось ГОРАЗДО проще поставить, чем копать ListView целиком (это одна не TOpenDialog, оно в десять раз больше). в принципе, если WideString не нужны, то использование TTableListVIewW не отличается от обычного.
а вот для WideString нужно делать следующее: 
все строки в Item'ах должны быть установлены функцией MakeWideCaption. а если нужно читать значения из таких полей, то используется StringOf.
примеры:
TableListView.Items.Add(TableListView.MakeWideCaption( FileName ));
TableListView.SubItems.Add(TableListView.MakeWideCaption( FileName ));
...
MessageBoxW( ... TableListView.StringOf(TableListView.Items[0].Caption) ... );

p.s: StringOf можно использовать не обязательно на полях, установленных MakeWideCaption, она будет работать и на любых других.