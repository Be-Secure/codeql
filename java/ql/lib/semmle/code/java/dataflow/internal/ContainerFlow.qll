import java
import semmle.code.java.Collections
import semmle.code.java.Maps
private import semmle.code.java.dataflow.SSA
private import DataFlowUtil
private import semmle.code.java.dataflow.ExternalFlow

private class EntryType extends RefType {
  EntryType() {
    this.getSourceDeclaration().getASourceSupertype*().hasQualifiedName("java.util", "Map$Entry")
  }

  RefType getValueType() {
    exists(GenericType t | t.hasQualifiedName("java.util", "Map$Entry") |
      indirectlyInstantiates(this, t, 1, result)
    )
  }
}

private class IterableType extends RefType {
  IterableType() {
    this.getSourceDeclaration().getASourceSupertype*().hasQualifiedName("java.lang", "Iterable")
  }

  RefType getElementType() {
    exists(GenericType t | t.hasQualifiedName("java.lang", "Iterable") |
      indirectlyInstantiates(this, t, 0, result)
    )
  }
}

private class IteratorType extends RefType {
  IteratorType() {
    this.getSourceDeclaration().getASourceSupertype*().hasQualifiedName("java.util", "Iterator")
  }

  RefType getElementType() {
    exists(GenericType t | t.hasQualifiedName("java.util", "Iterator") |
      indirectlyInstantiates(this, t, 0, result)
    )
  }
}

private class EnumerationType extends RefType {
  EnumerationType() {
    this.getSourceDeclaration().getASourceSupertype*().hasQualifiedName("java.util", "Enumeration")
  }

  RefType getElementType() {
    exists(GenericType t | t.hasQualifiedName("java.util", "Enumeration") |
      indirectlyInstantiates(this, t, 0, result)
    )
  }
}

/**
 * A type that acts as a container. This includes collections, maps, iterators,
 * iterables, enumerations, and map entry pairs. For maps and map entry pairs
 * only the value component is considered to act as a container.
 */
class ContainerType extends RefType {
  ContainerType() {
    this instanceof EntryType or
    this instanceof IterableType or
    this instanceof IteratorType or
    this instanceof EnumerationType or
    this instanceof MapType or
    this instanceof CollectionType
  }

  /** Gets the type of the contained elements. */
  RefType getElementType() {
    result = this.(EntryType).getValueType() or
    result = this.(IterableType).getElementType() or
    result = this.(IteratorType).getElementType() or
    result = this.(EnumerationType).getElementType() or
    result = this.(MapType).getValueType() or
    result = this.(CollectionType).getElementType()
  }

  /**
   * Gets the type of the contained elements or its upper bound if the type is
   * a type variable or wildcard.
   */
  RefType getElementTypeBound() {
    exists(RefType e | e = this.getElementType() |
      result = e and not e instanceof BoundedType
      or
      result = e.(BoundedType).getAnUltimateUpperBoundType()
    )
  }
}

private class ContainerFlowSummaries extends SummaryModelCsv {
  override predicate row(string row) {
    row =
      [
        "java.lang;Object;true;clone;;;MapKey of Argument[-1];MapKey of ReturnValue;value",
        "java.lang;Object;true;clone;;;MapValue of Argument[-1];MapValue of ReturnValue;value",
        "java.lang;Object;true;clone;;;Element of Argument[-1];Element of ReturnValue;value",
        "java.util;Map$Entry;true;getKey;;;MapKey of Argument[-1];ReturnValue;value",
        "java.util;Map$Entry;true;getValue;;;MapValue of Argument[-1];ReturnValue;value",
        "java.util;Map$Entry;true;setValue;;;MapValue of Argument[-1];ReturnValue;value",
        "java.util;Map$Entry;true;setValue;;;Argument[0];MapValue of Argument[-1];value",
        "java.lang;Iterable;true;iterator;();;Element of Argument[-1];Element of ReturnValue;value",
        "java.lang;Iterable;true;spliterator;();;Element of Argument[-1];Element of ReturnValue;value",
        "java.util;Iterator;true;next;;;Element of Argument[-1];ReturnValue;value",
        "java.util;ListIterator;true;previous;;;Element of Argument[-1];ReturnValue;value",
        "java.util;ListIterator;true;add;(Object);;Argument[0];Element of Argument[-1];value",
        "java.util;ListIterator;true;set;(Object);;Argument[0];Element of Argument[-1];value",
        "java.util;Enumeration;true;asIterator;;;Element of Argument[-1];Element of ReturnValue;value",
        "java.util;Enumeration;true;nextElement;;;Element of Argument[-1];ReturnValue;value",
        "java.util;Map;true;computeIfAbsent;;;MapValue of Argument[-1];ReturnValue;value",
        "java.util;Map;true;computeIfAbsent;;;ReturnValue of Argument[1];ReturnValue;value",
        "java.util;Map;true;computeIfAbsent;;;ReturnValue of Argument[1];MapValue of Argument[-1];value",
        "java.util;Map;true;entrySet;;;MapValue of Argument[-1];MapValue of Element of ReturnValue;value",
        "java.util;Map;true;entrySet;;;MapKey of Argument[-1];MapKey of Element of ReturnValue;value",
        "java.util;Map;true;get;;;MapValue of Argument[-1];ReturnValue;value",
        "java.util;Map;true;getOrDefault;;;MapValue of Argument[-1];ReturnValue;value",
        "java.util;Map;true;getOrDefault;;;Argument[1];ReturnValue;value",
        "java.util;Map;true;put;(Object,Object);;MapValue of Argument[-1];ReturnValue;value",
        "java.util;Map;true;put;(Object,Object);;Argument[0];MapKey of Argument[-1];value",
        "java.util;Map;true;put;(Object,Object);;Argument[1];MapValue of Argument[-1];value",
        "java.util;Map;true;putIfAbsent;;;MapValue of Argument[-1];ReturnValue;value",
        "java.util;Map;true;putIfAbsent;;;Argument[0];MapKey of Argument[-1];value",
        "java.util;Map;true;putIfAbsent;;;Argument[1];MapValue of Argument[-1];value",
        "java.util;Map;true;remove;(Object);;MapValue of Argument[-1];ReturnValue;value",
        "java.util;Map;true;replace;(Object,Object);;MapValue of Argument[-1];ReturnValue;value",
        "java.util;Map;true;replace;(Object,Object);;Argument[0];MapKey of Argument[-1];value",
        "java.util;Map;true;replace;(Object,Object);;Argument[1];MapValue of Argument[-1];value",
        "java.util;Map;true;replace;(Object,Object,Object);;Argument[0];MapKey of Argument[-1];value",
        "java.util;Map;true;replace;(Object,Object,Object);;Argument[2];MapValue of Argument[-1];value",
        "java.util;Map;true;keySet;();;MapKey of Argument[-1];Element of ReturnValue;value",
        "java.util;Map;true;values;();;MapValue of Argument[-1];Element of ReturnValue;value",
        "java.util;Map;true;merge;(Object,Object,BiFunction);;Argument[1];MapValue of Argument[-1];value",
        "java.util;Map;true;putAll;(Map);;MapKey of Argument[0];MapKey of Argument[-1];value",
        "java.util;Map;true;putAll;(Map);;MapValue of Argument[0];MapValue of Argument[-1];value",
        "java.util;Collection;true;parallelStream;();;Element of Argument[-1];Element of ReturnValue;value",
        "java.util;Collection;true;stream;();;Element of Argument[-1];Element of ReturnValue;value",
        "java.util;Collection;true;toArray;;;Element of Argument[-1];ArrayElement of ReturnValue;value",
        "java.util;Collection;true;toArray;;;Element of Argument[-1];ArrayElement of Argument[0];value",
        "java.util;Collection;true;add;;;Argument[0];Element of Argument[-1];value",
        "java.util;Collection;true;addAll;;;Element of Argument[0];Element of Argument[-1];value",
        "java.util;List;true;get;(int);;Element of Argument[-1];ReturnValue;value",
        "java.util;List;true;listIterator;;;Element of Argument[-1];Element of ReturnValue;value",
        "java.util;List;true;remove;(int);;Element of Argument[-1];ReturnValue;value",
        "java.util;List;true;set;(int,Object);;Element of Argument[-1];ReturnValue;value",
        "java.util;List;true;set;(int,Object);;Argument[1];Element of Argument[-1];value",
        "java.util;List;true;subList;;;Element of Argument[-1];Element of ReturnValue;value",
        "java.util;List;true;add;(int,Object);;Argument[1];Element of Argument[-1];value",
        "java.util;List;true;addAll;(int,Collection);;Element of Argument[1];Element of Argument[-1];value",
        "java.util;Vector;true;elementAt;(int);;Element of Argument[-1];ReturnValue;value",
        "java.util;Vector;true;elements;();;Element of Argument[-1];Element of ReturnValue;value",
        "java.util;Vector;true;firstElement;();;Element of Argument[-1];ReturnValue;value",
        "java.util;Vector;true;lastElement;();;Element of Argument[-1];ReturnValue;value",
        "java.util;Vector;true;addElement;(Object);;Argument[0];Element of Argument[-1];value",
        "java.util;Vector;true;insertElementAt;(Object,int);;Argument[0];Element of Argument[-1];value",
        "java.util;Vector;true;setElementAt;(Object,int);;Argument[0];Element of Argument[-1];value",
        "java.util;Vector;true;copyInto;(Object[]);;Element of Argument[-1];ArrayElement of Argument[0];value",
        "java.util;Stack;true;peek;();;Element of Argument[-1];ReturnValue;value",
        "java.util;Stack;true;pop;();;Element of Argument[-1];ReturnValue;value",
        "java.util;Stack;true;push;(Object);;Argument[0];Element of Argument[-1];value",
        "java.util;Queue;true;element;();;Element of Argument[-1];ReturnValue;value",
        "java.util;Queue;true;peek;();;Element of Argument[-1];ReturnValue;value",
        "java.util;Queue;true;poll;();;Element of Argument[-1];ReturnValue;value",
        "java.util;Queue;true;remove;();;Element of Argument[-1];ReturnValue;value",
        "java.util;Queue;true;offer;(Object);;Argument[0];Element of Argument[-1];value",
        "java.util;Deque;true;descendingIterator;();;Element of Argument[-1];Element of ReturnValue;value",
        "java.util;Deque;true;getFirst;();;Element of Argument[-1];ReturnValue;value",
        "java.util;Deque;true;getLast;();;Element of Argument[-1];ReturnValue;value",
        "java.util;Deque;true;peekFirst;();;Element of Argument[-1];ReturnValue;value",
        "java.util;Deque;true;peekLast;();;Element of Argument[-1];ReturnValue;value",
        "java.util;Deque;true;pollFirst;();;Element of Argument[-1];ReturnValue;value",
        "java.util;Deque;true;pollLast;();;Element of Argument[-1];ReturnValue;value",
        "java.util;Deque;true;pop;();;Element of Argument[-1];ReturnValue;value",
        "java.util;Deque;true;removeFirst;();;Element of Argument[-1];ReturnValue;value",
        "java.util;Deque;true;removeLast;();;Element of Argument[-1];ReturnValue;value",
        "java.util;Deque;true;push;(Object);;Argument[0];Element of Argument[-1];value",
        "java.util;Deque;true;offerLast;(Object);;Argument[0];Element of Argument[-1];value",
        "java.util;Deque;true;offerFirst;(Object);;Argument[0];Element of Argument[-1];value",
        "java.util;Deque;true;addLast;(Object);;Argument[0];Element of Argument[-1];value",
        "java.util;Deque;true;addFirst;(Object);;Argument[0];Element of Argument[-1];value",
        "java.util.concurrent;BlockingDeque;true;pollFirst;(long,TimeUnit);;Element of Argument[-1];ReturnValue;value",
        "java.util.concurrent;BlockingDeque;true;pollLast;(long,TimeUnit);;Element of Argument[-1];ReturnValue;value",
        "java.util.concurrent;BlockingDeque;true;takeFirst;();;Element of Argument[-1];ReturnValue;value",
        "java.util.concurrent;BlockingDeque;true;takeLast;();;Element of Argument[-1];ReturnValue;value",
        "java.util.concurrent;BlockingQueue;true;poll;(long,TimeUnit);;Element of Argument[-1];ReturnValue;value",
        "java.util.concurrent;BlockingQueue;true;take;();;Element of Argument[-1];ReturnValue;value",
        "java.util.concurrent;BlockingQueue;true;offer;(Object,long,TimeUnit);;Argument[0];Element of Argument[-1];value",
        "java.util.concurrent;BlockingQueue;true;put;(Object);;Argument[0];Element of Argument[-1];value",
        "java.util.concurrent;BlockingDeque;true;offerLast;(Object,long,TimeUnit);;Argument[0];Element of Argument[-1];value",
        "java.util.concurrent;BlockingDeque;true;offerFirst;(Object,long,TimeUnit);;Argument[0];Element of Argument[-1];value",
        "java.util.concurrent;BlockingDeque;true;putLast;(Object);;Argument[0];Element of Argument[-1];value",
        "java.util.concurrent;BlockingDeque;true;putFirst;(Object);;Argument[0];Element of Argument[-1];value",
        "java.util.concurrent;BlockingQueue;true;drainTo;(Collection,int);;Element of Argument[-1];Element of Argument[0];value",
        "java.util.concurrent;BlockingQueue;true;drainTo;(Collection);;Element of Argument[-1];Element of Argument[0];value",
        "java.util.concurrent;ConcurrentHashMap;true;elements;();;MapValue of Argument[-1];Element of ReturnValue;value",
        "java.util;Dictionary;true;elements;();;MapValue of Argument[-1];Element of ReturnValue;value",
        "java.util;Dictionary;true;get;(Object);;MapValue of Argument[-1];ReturnValue;value",
        "java.util;Dictionary;true;keys;();;MapKey of Argument[-1];Element of ReturnValue;value",
        "java.util;Dictionary;true;put;(Object,Object);;MapValue of Argument[-1];ReturnValue;value",
        "java.util;Dictionary;true;put;(Object,Object);;Argument[0];MapKey of Argument[-1];value",
        "java.util;Dictionary;true;put;(Object,Object);;Argument[1];MapValue of Argument[-1];value",
        "java.util;Dictionary;true;remove;(Object);;MapValue of Argument[-1];ReturnValue;value",
        "java.util;NavigableMap;true;ceilingEntry;(Object);;MapKey of Argument[-1];MapKey of ReturnValue;value",
        "java.util;NavigableMap;true;ceilingEntry;(Object);;MapValue of Argument[-1];MapValue of ReturnValue;value",
        "java.util;NavigableMap;true;descendingMap;();;MapKey of Argument[-1];MapKey of ReturnValue;value",
        "java.util;NavigableMap;true;descendingMap;();;MapValue of Argument[-1];MapValue of ReturnValue;value",
        "java.util;NavigableMap;true;firstEntry;();;MapKey of Argument[-1];MapKey of ReturnValue;value",
        "java.util;NavigableMap;true;firstEntry;();;MapValue of Argument[-1];MapValue of ReturnValue;value",
        "java.util;NavigableMap;true;floorEntry;(Object);;MapKey of Argument[-1];MapKey of ReturnValue;value",
        "java.util;NavigableMap;true;floorEntry;(Object);;MapValue of Argument[-1];MapValue of ReturnValue;value",
        "java.util;NavigableMap;true;headMap;(Object,boolean);;MapKey of Argument[-1];MapKey of ReturnValue;value",
        "java.util;NavigableMap;true;headMap;(Object,boolean);;MapValue of Argument[-1];MapValue of ReturnValue;value",
        "java.util;NavigableMap;true;higherEntry;(Object);;MapKey of Argument[-1];MapKey of ReturnValue;value",
        "java.util;NavigableMap;true;higherEntry;(Object);;MapValue of Argument[-1];MapValue of ReturnValue;value",
        "java.util;NavigableMap;true;lastEntry;();;MapKey of Argument[-1];MapKey of ReturnValue;value",
        "java.util;NavigableMap;true;lastEntry;();;MapValue of Argument[-1];MapValue of ReturnValue;value",
        "java.util;NavigableMap;true;lowerEntry;(Object);;MapKey of Argument[-1];MapKey of ReturnValue;value",
        "java.util;NavigableMap;true;lowerEntry;(Object);;MapValue of Argument[-1];MapValue of ReturnValue;value",
        "java.util;NavigableMap;true;pollFirstEntry;();;MapKey of Argument[-1];MapKey of ReturnValue;value",
        "java.util;NavigableMap;true;pollFirstEntry;();;MapValue of Argument[-1];MapValue of ReturnValue;value",
        "java.util;NavigableMap;true;pollLastEntry;();;MapKey of Argument[-1];MapKey of ReturnValue;value",
        "java.util;NavigableMap;true;pollLastEntry;();;MapValue of Argument[-1];MapValue of ReturnValue;value",
        "java.util;NavigableMap;true;subMap;(Object,boolean,Object,boolean);;MapKey of Argument[-1];MapKey of ReturnValue;value",
        "java.util;NavigableMap;true;subMap;(Object,boolean,Object,boolean);;MapValue of Argument[-1];MapValue of ReturnValue;value",
        "java.util;NavigableMap;true;tailMap;(Object,boolean);;MapKey of Argument[-1];MapKey of ReturnValue;value",
        "java.util;NavigableMap;true;tailMap;(Object,boolean);;MapValue of Argument[-1];MapValue of ReturnValue;value",
        "java.util;NavigableSet;true;ceiling;(Object);;Element of Argument[-1];ReturnValue;value",
        "java.util;NavigableSet;true;descendingIterator;();;Element of Argument[-1];Element of ReturnValue;value",
        "java.util;NavigableSet;true;descendingSet;();;Element of Argument[-1];Element of ReturnValue;value",
        "java.util;NavigableSet;true;floor;(Object);;Element of Argument[-1];ReturnValue;value",
        "java.util;NavigableSet;true;headSet;(Object,boolean);;Element of Argument[-1];Element of ReturnValue;value",
        "java.util;NavigableSet;true;higher;(Object);;Element of Argument[-1];ReturnValue;value",
        "java.util;NavigableSet;true;lower;(Object);;Element of Argument[-1];ReturnValue;value",
        "java.util;NavigableSet;true;pollFirst;();;Element of Argument[-1];ReturnValue;value",
        "java.util;NavigableSet;true;pollLast;();;Element of Argument[-1];ReturnValue;value",
        "java.util;NavigableSet;true;subSet;(Object,boolean,Object,boolean);;Element of Argument[-1];Element of ReturnValue;value",
        "java.util;NavigableSet;true;tailSet;(Object,boolean);;Element of Argument[-1];Element of ReturnValue;value",
        "java.util;Scanner;true;next;(Pattern);;Argument[-1];ReturnValue;taint",
        "java.util;Scanner;true;next;(String);;Argument[-1];ReturnValue;taint",
        "java.util;SortedMap;true;headMap;(Object);;MapKey of Argument[-1];MapKey of ReturnValue;value",
        "java.util;SortedMap;true;headMap;(Object);;MapValue of Argument[-1];MapValue of ReturnValue;value",
        "java.util;SortedMap;true;subMap;(Object,Object);;MapKey of Argument[-1];MapKey of ReturnValue;value",
        "java.util;SortedMap;true;subMap;(Object,Object);;MapValue of Argument[-1];MapValue of ReturnValue;value",
        "java.util;SortedMap;true;tailMap;(Object);;MapKey of Argument[-1];MapKey of ReturnValue;value",
        "java.util;SortedMap;true;tailMap;(Object);;MapValue of Argument[-1];MapValue of ReturnValue;value",
        "java.util;SortedSet;true;first;();;Element of Argument[-1];ReturnValue;value",
        "java.util;SortedSet;true;headSet;(Object);;Element of Argument[-1];Element of ReturnValue;value",
        "java.util;SortedSet;true;last;();;Element of Argument[-1];ReturnValue;value",
        "java.util;SortedSet;true;subSet;(Object,Object);;Element of Argument[-1];Element of ReturnValue;value",
        "java.util;SortedSet;true;tailSet;(Object);;Element of Argument[-1];Element of ReturnValue;value",
        "java.util.concurrent;TransferQueue;true;tryTransfer;(Object,long,TimeUnit);;Argument[0];Element of Argument[-1];value",
        "java.util.concurrent;TransferQueue;true;transfer;(Object);;Argument[0];Element of Argument[-1];value",
        "java.util.concurrent;TransferQueue;true;tryTransfer;(Object);;Argument[0];Element of Argument[-1];value",
        "java.util;List;false;copyOf;(Collection);;Element of Argument[0];Element of ReturnValue;value",
        "java.util;List;false;of;(Object[]);;ArrayElement of Argument[0];Element of ReturnValue;value",
        "java.util;List;false;of;(Object);;Argument[0];Element of ReturnValue;value",
        "java.util;List;false;of;(Object,Object);;Argument[0..1];Element of ReturnValue;value",
        "java.util;List;false;of;(Object,Object,Object);;Argument[0..2];Element of ReturnValue;value",
        "java.util;List;false;of;(Object,Object,Object,Object);;Argument[0..3];Element of ReturnValue;value",
        "java.util;List;false;of;(Object,Object,Object,Object,Object);;Argument[0..4];Element of ReturnValue;value",
        "java.util;List;false;of;(Object,Object,Object,Object,Object,Object);;Argument[0..5];Element of ReturnValue;value",
        "java.util;List;false;of;(Object,Object,Object,Object,Object,Object,Object);;Argument[0..6];Element of ReturnValue;value",
        "java.util;List;false;of;(Object,Object,Object,Object,Object,Object,Object,Object);;Argument[0..7];Element of ReturnValue;value",
        "java.util;List;false;of;(Object,Object,Object,Object,Object,Object,Object,Object,Object);;Argument[0..8];Element of ReturnValue;value",
        "java.util;List;false;of;(Object,Object,Object,Object,Object,Object,Object,Object,Object,Object);;Argument[0..9];Element of ReturnValue;value",
        "java.util;Map;false;copyOf;(Map);;MapKey of Argument[0];MapKey of ReturnValue;value",
        "java.util;Map;false;copyOf;(Map);;MapValue of Argument[0];MapValue of ReturnValue;value",
        "java.util;Map;false;entry;(Object,Object);;Argument[0];MapKey of ReturnValue;value",
        "java.util;Map;false;entry;(Object,Object);;Argument[1];MapValue of ReturnValue;value",
        "java.util;Map;false;of;;;Argument[0];MapKey of ReturnValue;value",
        "java.util;Map;false;of;;;Argument[1];MapValue of ReturnValue;value",
        "java.util;Map;false;of;;;Argument[2];MapKey of ReturnValue;value",
        "java.util;Map;false;of;;;Argument[3];MapValue of ReturnValue;value",
        "java.util;Map;false;of;;;Argument[4];MapKey of ReturnValue;value",
        "java.util;Map;false;of;;;Argument[5];MapValue of ReturnValue;value",
        "java.util;Map;false;of;;;Argument[6];MapKey of ReturnValue;value",
        "java.util;Map;false;of;;;Argument[7];MapValue of ReturnValue;value",
        "java.util;Map;false;of;;;Argument[8];MapKey of ReturnValue;value",
        "java.util;Map;false;of;;;Argument[9];MapValue of ReturnValue;value",
        "java.util;Map;false;of;;;Argument[10];MapKey of ReturnValue;value",
        "java.util;Map;false;of;;;Argument[11];MapValue of ReturnValue;value",
        "java.util;Map;false;of;;;Argument[12];MapKey of ReturnValue;value",
        "java.util;Map;false;of;;;Argument[13];MapValue of ReturnValue;value",
        "java.util;Map;false;of;;;Argument[14];MapKey of ReturnValue;value",
        "java.util;Map;false;of;;;Argument[15];MapValue of ReturnValue;value",
        "java.util;Map;false;of;;;Argument[16];MapKey of ReturnValue;value",
        "java.util;Map;false;of;;;Argument[17];MapValue of ReturnValue;value",
        "java.util;Map;false;of;;;Argument[18];MapKey of ReturnValue;value",
        "java.util;Map;false;of;;;Argument[19];MapValue of ReturnValue;value",
        "java.util;Map;false;ofEntries;;;MapKey of ArrayElement of Argument[0];MapKey of ReturnValue;value",
        "java.util;Map;false;ofEntries;;;MapValue of ArrayElement of Argument[0];MapValue of ReturnValue;value",
        "java.util;Set;false;copyOf;(Collection);;Element of Argument[0];Element of ReturnValue;value",
        "java.util;Set;false;of;(Object[]);;ArrayElement of Argument[0];Element of ReturnValue;value",
        "java.util;Set;false;of;(Object);;Argument[0];Element of ReturnValue;value",
        "java.util;Set;false;of;(Object,Object);;Argument[0..1];Element of ReturnValue;value",
        "java.util;Set;false;of;(Object,Object,Object);;Argument[0..2];Element of ReturnValue;value",
        "java.util;Set;false;of;(Object,Object,Object,Object);;Argument[0..3];Element of ReturnValue;value",
        "java.util;Set;false;of;(Object,Object,Object,Object,Object);;Argument[0..4];Element of ReturnValue;value",
        "java.util;Set;false;of;(Object,Object,Object,Object,Object,Object);;Argument[0..5];Element of ReturnValue;value",
        "java.util;Set;false;of;(Object,Object,Object,Object,Object,Object,Object);;Argument[0..6];Element of ReturnValue;value",
        "java.util;Set;false;of;(Object,Object,Object,Object,Object,Object,Object,Object);;Argument[0..7];Element of ReturnValue;value",
        "java.util;Set;false;of;(Object,Object,Object,Object,Object,Object,Object,Object,Object);;Argument[0..8];Element of ReturnValue;value",
        "java.util;Set;false;of;(Object,Object,Object,Object,Object,Object,Object,Object,Object,Object);;Argument[0..9];Element of ReturnValue;value",
        "java.util;Arrays;false;stream;;;ArrayElement of Argument[0];Element of ReturnValue;value",
        "java.util;Arrays;false;spliterator;;;ArrayElement of Argument[0];Element of ReturnValue;value",
        "java.util;Arrays;false;copyOfRange;;;ArrayElement of Argument[0];ArrayElement of ReturnValue;value",
        "java.util;Arrays;false;copyOf;;;ArrayElement of Argument[0];ArrayElement of ReturnValue;value",
        "java.util;Collections;false;list;(Enumeration);;Element of Argument[0];Element of ReturnValue;value",
        "java.util;Collections;false;enumeration;(Collection);;Element of Argument[0];Element of ReturnValue;value",
        "java.util;Collections;false;nCopies;(int,Object);;Argument[1];Element of ReturnValue;value",
        "java.util;Collections;false;singletonMap;(Object,Object);;Argument[0];MapKey of ReturnValue;value",
        "java.util;Collections;false;singletonMap;(Object,Object);;Argument[1];MapValue of ReturnValue;value",
        "java.util;Collections;false;singletonList;(Object);;Argument[0];Element of ReturnValue;value",
        "java.util;Collections;false;singleton;(Object);;Argument[0];Element of ReturnValue;value",
        "java.util;Collections;false;checkedNavigableMap;(NavigableMap,Class,Class);;MapKey of Argument[0];MapKey of ReturnValue;value",
        "java.util;Collections;false;checkedNavigableMap;(NavigableMap,Class,Class);;MapValue of Argument[0];MapValue of ReturnValue;value",
        "java.util;Collections;false;checkedSortedMap;(SortedMap,Class,Class);;MapKey of Argument[0];MapKey of ReturnValue;value",
        "java.util;Collections;false;checkedSortedMap;(SortedMap,Class,Class);;MapValue of Argument[0];MapValue of ReturnValue;value",
        "java.util;Collections;false;checkedMap;(Map,Class,Class);;MapKey of Argument[0];MapKey of ReturnValue;value",
        "java.util;Collections;false;checkedMap;(Map,Class,Class);;MapValue of Argument[0];MapValue of ReturnValue;value",
        "java.util;Collections;false;checkedList;(List,Class);;Element of Argument[0];Element of ReturnValue;value",
        "java.util;Collections;false;checkedNavigableSet;(NavigableSet,Class);;Element of Argument[0];Element of ReturnValue;value",
        "java.util;Collections;false;checkedSortedSet;(SortedSet,Class);;Element of Argument[0];Element of ReturnValue;value",
        "java.util;Collections;false;checkedSet;(Set,Class);;Element of Argument[0];Element of ReturnValue;value",
        "java.util;Collections;false;checkedCollection;(Collection,Class);;Element of Argument[0];Element of ReturnValue;value",
        "java.util;Collections;false;synchronizedNavigableMap;(NavigableMap);;MapKey of Argument[0];MapKey of ReturnValue;value",
        "java.util;Collections;false;synchronizedNavigableMap;(NavigableMap);;MapValue of Argument[0];MapValue of ReturnValue;value",
        "java.util;Collections;false;synchronizedSortedMap;(SortedMap);;MapKey of Argument[0];MapKey of ReturnValue;value",
        "java.util;Collections;false;synchronizedSortedMap;(SortedMap);;MapValue of Argument[0];MapValue of ReturnValue;value",
        "java.util;Collections;false;synchronizedMap;(Map);;MapKey of Argument[0];MapKey of ReturnValue;value",
        "java.util;Collections;false;synchronizedMap;(Map);;MapValue of Argument[0];MapValue of ReturnValue;value",
        "java.util;Collections;false;synchronizedList;(List);;Element of Argument[0];Element of ReturnValue;value",
        "java.util;Collections;false;synchronizedNavigableSet;(NavigableSet);;Element of Argument[0];Element of ReturnValue;value",
        "java.util;Collections;false;synchronizedSortedSet;(SortedSet);;Element of Argument[0];Element of ReturnValue;value",
        "java.util;Collections;false;synchronizedSet;(Set);;Element of Argument[0];Element of ReturnValue;value",
        "java.util;Collections;false;synchronizedCollection;(Collection);;Element of Argument[0];Element of ReturnValue;value",
        "java.util;Collections;false;unmodifiableNavigableMap;(NavigableMap);;MapKey of Argument[0];MapKey of ReturnValue;value",
        "java.util;Collections;false;unmodifiableNavigableMap;(NavigableMap);;MapValue of Argument[0];MapValue of ReturnValue;value",
        "java.util;Collections;false;unmodifiableSortedMap;(SortedMap);;MapKey of Argument[0];MapKey of ReturnValue;value",
        "java.util;Collections;false;unmodifiableSortedMap;(SortedMap);;MapValue of Argument[0];MapValue of ReturnValue;value",
        "java.util;Collections;false;unmodifiableMap;(Map);;MapKey of Argument[0];MapKey of ReturnValue;value",
        "java.util;Collections;false;unmodifiableMap;(Map);;MapValue of Argument[0];MapValue of ReturnValue;value",
        "java.util;Collections;false;unmodifiableList;(List);;Element of Argument[0];Element of ReturnValue;value",
        "java.util;Collections;false;unmodifiableNavigableSet;(NavigableSet);;Element of Argument[0];Element of ReturnValue;value",
        "java.util;Collections;false;unmodifiableSortedSet;(SortedSet);;Element of Argument[0];Element of ReturnValue;value",
        "java.util;Collections;false;unmodifiableSet;(Set);;Element of Argument[0];Element of ReturnValue;value",
        "java.util;Collections;false;unmodifiableCollection;(Collection);;Element of Argument[0];Element of ReturnValue;value",
        "java.util;Collections;false;max;;;Element of Argument[0];ReturnValue;value",
        "java.util;Collections;false;min;;;Element of Argument[0];ReturnValue;value",
        "java.util;Arrays;false;fill;(Object[],int,int,Object);;Argument[3];ArrayElement of Argument[0];value",
        "java.util;Arrays;false;fill;(Object[],Object);;Argument[1];ArrayElement of Argument[0];value",
        "java.util;Arrays;false;fill;(float[],int,int,float);;Argument[3];ArrayElement of Argument[0];value",
        "java.util;Arrays;false;fill;(float[],float);;Argument[1];ArrayElement of Argument[0];value",
        "java.util;Arrays;false;fill;(double[],int,int,double);;Argument[3];ArrayElement of Argument[0];value",
        "java.util;Arrays;false;fill;(double[],double);;Argument[1];ArrayElement of Argument[0];value",
        "java.util;Arrays;false;fill;(boolean[],int,int,boolean);;Argument[3];ArrayElement of Argument[0];value",
        "java.util;Arrays;false;fill;(boolean[],boolean);;Argument[1];ArrayElement of Argument[0];value",
        "java.util;Arrays;false;fill;(byte[],int,int,byte);;Argument[3];ArrayElement of Argument[0];value",
        "java.util;Arrays;false;fill;(byte[],byte);;Argument[1];ArrayElement of Argument[0];value",
        "java.util;Arrays;false;fill;(char[],int,int,char);;Argument[3];ArrayElement of Argument[0];value",
        "java.util;Arrays;false;fill;(char[],char);;Argument[1];ArrayElement of Argument[0];value",
        "java.util;Arrays;false;fill;(short[],int,int,short);;Argument[3];ArrayElement of Argument[0];value",
        "java.util;Arrays;false;fill;(short[],short);;Argument[1];ArrayElement of Argument[0];value",
        "java.util;Arrays;false;fill;(int[],int,int,int);;Argument[3];ArrayElement of Argument[0];value",
        "java.util;Arrays;false;fill;(int[],int);;Argument[1];ArrayElement of Argument[0];value",
        "java.util;Arrays;false;fill;(long[],int,int,long);;Argument[3];ArrayElement of Argument[0];value",
        "java.util;Arrays;false;fill;(long[],long);;Argument[1];ArrayElement of Argument[0];value",
        "java.util;Collections;false;replaceAll;(List,Object,Object);;Argument[2];Element of Argument[0];value",
        "java.util;Collections;false;copy;(List,List);;Element of Argument[1];Element of Argument[0];value",
        "java.util;Collections;false;fill;(List,Object);;Argument[1];Element of Argument[0];value",
        "java.util;Arrays;false;asList;;;ArrayElement of Argument[0];Element of ReturnValue;value",
        "java.util;Collections;false;addAll;(Collection,Object[]);;ArrayElement of Argument[1];Element of Argument[0];value",
        "java.util;AbstractMap$SimpleEntry;false;SimpleEntry;(Object,Object);;Argument[0];MapKey of Argument[-1];value",
        "java.util;AbstractMap$SimpleEntry;false;SimpleEntry;(Object,Object);;Argument[1];MapValue of Argument[-1];value",
        "java.util;AbstractMap$SimpleEntry;false;SimpleEntry;(Entry);;MapKey of Argument[0];MapKey of Argument[-1];value",
        "java.util;AbstractMap$SimpleEntry;false;SimpleEntry;(Entry);;MapValue of Argument[0];MapValue of Argument[-1];value",
        "java.util;AbstractMap$SimpleImmutableEntry;false;SimpleImmutableEntry;(Object,Object);;Argument[0];MapKey of Argument[-1];value",
        "java.util;AbstractMap$SimpleImmutableEntry;false;SimpleImmutableEntry;(Object,Object);;Argument[1];MapValue of Argument[-1];value",
        "java.util;AbstractMap$SimpleImmutableEntry;false;SimpleImmutableEntry;(Entry);;MapKey of Argument[0];MapKey of Argument[-1];value",
        "java.util;AbstractMap$SimpleImmutableEntry;false;SimpleImmutableEntry;(Entry);;MapValue of Argument[0];MapValue of Argument[-1];value",
        "java.util;ArrayDeque;false;ArrayDeque;(Collection);;Element of Argument[0];Element of Argument[-1];value",
        "java.util;ArrayList;false;ArrayList;(Collection);;Element of Argument[0];Element of Argument[-1];value",
        "java.util;EnumMap;false;EnumMap;(Map);;MapKey of Argument[0];MapKey of Argument[-1];value",
        "java.util;EnumMap;false;EnumMap;(Map);;MapValue of Argument[0];MapValue of Argument[-1];value",
        "java.util;EnumMap;false;EnumMap;(EnumMap);;MapKey of Argument[0];MapKey of Argument[-1];value",
        "java.util;EnumMap;false;EnumMap;(EnumMap);;MapValue of Argument[0];MapValue of Argument[-1];value",
        "java.util;HashMap;false;HashMap;(Map);;MapKey of Argument[0];MapKey of Argument[-1];value",
        "java.util;HashMap;false;HashMap;(Map);;MapValue of Argument[0];MapValue of Argument[-1];value",
        "java.util;HashSet;false;HashSet;(Collection);;Element of Argument[0];Element of Argument[-1];value",
        "java.util;Hashtable;false;Hashtable;(Map);;MapKey of Argument[0];MapKey of Argument[-1];value",
        "java.util;Hashtable;false;Hashtable;(Map);;MapValue of Argument[0];MapValue of Argument[-1];value",
        "java.util;IdentityHashMap;false;IdentityHashMap;(Map);;MapKey of Argument[0];MapKey of Argument[-1];value",
        "java.util;IdentityHashMap;false;IdentityHashMap;(Map);;MapValue of Argument[0];MapValue of Argument[-1];value",
        "java.util;LinkedHashMap;false;LinkedHashMap;(Map);;MapKey of Argument[0];MapKey of Argument[-1];value",
        "java.util;LinkedHashMap;false;LinkedHashMap;(Map);;MapValue of Argument[0];MapValue of Argument[-1];value",
        "java.util;LinkedHashSet;false;LinkedHashSet;(Collection);;Element of Argument[0];Element of Argument[-1];value",
        "java.util;LinkedList;false;LinkedList;(Collection);;Element of Argument[0];Element of Argument[-1];value",
        "java.util;PriorityQueue;false;PriorityQueue;(Collection);;Element of Argument[0];Element of Argument[-1];value",
        "java.util;PriorityQueue;false;PriorityQueue;(PriorityQueue);;Element of Argument[0];Element of Argument[-1];value",
        "java.util;PriorityQueue;false;PriorityQueue;(SortedSet);;Element of Argument[0];Element of Argument[-1];value",
        "java.util;TreeMap;false;TreeMap;(Map);;MapKey of Argument[0];MapKey of Argument[-1];value",
        "java.util;TreeMap;false;TreeMap;(Map);;MapValue of Argument[0];MapValue of Argument[-1];value",
        "java.util;TreeMap;false;TreeMap;(SortedMap);;MapKey of Argument[0];MapKey of Argument[-1];value",
        "java.util;TreeMap;false;TreeMap;(SortedMap);;MapValue of Argument[0];MapValue of Argument[-1];value",
        "java.util;TreeSet;false;TreeSet;(Collection);;Element of Argument[0];Element of Argument[-1];value",
        "java.util;TreeSet;false;TreeSet;(SortedSet);;Element of Argument[0];Element of Argument[-1];value",
        "java.util;Vector;false;Vector;(Collection);;Element of Argument[0];Element of Argument[-1];value",
        "java.util;WeakHashMap;false;WeakHashMap;(Map);;MapKey of Argument[0];MapKey of Argument[-1];value",
        "java.util;WeakHashMap;false;WeakHashMap;(Map);;MapValue of Argument[0];MapValue of Argument[-1];value"
      ]
  }
}

private predicate taintPreservingQualifierToMethod(Method m) {
  // java.util.Map.Entry
  m.getDeclaringType() instanceof EntryType and
  m.hasName(["getValue", "setValue"])
  or
  // java.util.Iterable
  m.getDeclaringType() instanceof IterableType and
  m.hasName(["iterator", "spliterator"])
  or
  // java.util.Iterator
  m.getDeclaringType() instanceof IteratorType and
  m.hasName("next")
  or
  // java.util.ListIterator
  m.getDeclaringType() instanceof IteratorType and
  m.hasName("previous")
  or
  // java.util.Enumeration
  m.getDeclaringType() instanceof EnumerationType and
  m.hasName(["asIterator", "nextElement"])
  or
  // java.util.Map
  m.(MapMethod)
      .hasName([
          "computeIfAbsent", "entrySet", "get", "getOrDefault", "put", "putIfAbsent", "remove",
          "replace", "values"
        ])
  or
  // java.util.Collection
  m.(CollectionMethod).hasName(["parallelStream", "stream", "toArray"])
  or
  // java.util.List
  m.(CollectionMethod).hasName(["get", "listIterator", "set", "subList"])
  or
  m.(CollectionMethod).hasName("remove") and m.getParameterType(0).(PrimitiveType).hasName("int")
  or
  // java.util.Vector
  m.(CollectionMethod).hasName(["elementAt", "elements", "firstElement", "lastElement"])
  or
  // java.util.Stack
  m.(CollectionMethod).hasName(["peek", "pop"])
  or
  // java.util.Queue
  // covered by Stack: peek()
  m.(CollectionMethod).hasName(["element", "poll"])
  or
  m.(CollectionMethod).hasName("remove") and m.getNumberOfParameters() = 0
  or
  // java.util.Deque
  m.(CollectionMethod)
      .hasName([
          "getFirst", "getLast", "peekFirst", "peekLast", "pollFirst", "pollLast", "removeFirst",
          "removeLast"
        ])
  or
  // java.util.concurrent.BlockingQueue
  // covered by Queue: poll(long, TimeUnit)
  m.(CollectionMethod).hasName("take")
  or
  // java.util.concurrent.BlockingDeque
  // covered by Deque: pollFirst(long, TimeUnit), pollLast(long, TimeUnit)
  m.(CollectionMethod).hasName(["takeFirst", "takeLast"])
  or
  // java.util.SortedSet
  m.(CollectionMethod).hasName(["first", "headSet", "last", "subSet", "tailSet"])
  or
  // java.util.NavigableSet
  // covered by Deque: pollFirst(), pollLast()
  // covered by SortedSet: headSet(E, boolean), subSet(E, boolean, E, boolean) and tailSet(E, boolean)
  m.(CollectionMethod)
      .hasName(["ceiling", "descendingIterator", "descendingSet", "floor", "higher", "lower"])
  or
  // java.util.SortedMap
  m.(MapMethod).hasName(["headMap", "subMap", "tailMap"])
  or
  // java.util.NavigableMap
  // covered by SortedMap: headMap(K, boolean), subMap(K, boolean, K, boolean), tailMap(K, boolean)
  m.(MapMethod)
      .hasName([
          "ceilingEntry", "descendingMap", "firstEntry", "floorEntry", "higherEntry", "lastEntry",
          "lowerEntry", "pollFirstEntry", "pollLastEntry"
        ])
  or
  // java.util.Dictionary
  m.getDeclaringType()
      .getSourceDeclaration()
      .getASourceSupertype*()
      .hasQualifiedName("java.util", "Dictionary") and
  m.hasName(["elements", "get", "put", "remove"])
  or
  // java.util.concurrent.ConcurrentHashMap
  m.(MapMethod).hasName(["elements", "search", "searchEntries", "searchValues"])
}

private predicate qualifierToMethodStep(Expr tracked, MethodAccess sink) {
  taintPreservingQualifierToMethod(sink.getMethod()) and
  tracked = sink.getQualifier()
}

private predicate qualifierToArgumentStep(Expr tracked, Expr sink) {
  exists(MethodAccess ma, CollectionMethod method |
    method = ma.getMethod() and
    (
      // java.util.Vector
      method.hasName("copyInto")
      or
      // java.util.concurrent.BlockingQueue
      method.hasName("drainTo")
      or
      // java.util.Collection
      method.hasName("toArray") and method.getParameter(0).getType() instanceof Array
    ) and
    tracked = ma.getQualifier() and
    sink = ma.getArgument(0)
  )
}

private predicate taintPreservingArgumentToQualifier(Method method, int arg) {
  // java.util.Map.Entry
  method.getDeclaringType() instanceof EntryType and
  method.hasName("setValue") and
  arg = 0
  or
  // java.util.Map
  method.(MapMethod).hasName(["merge", "put", "putIfAbsent"]) and arg = 1
  or
  method.(MapMethod).hasName("replace") and arg = method.getNumberOfParameters() - 1
  or
  method.(MapMethod).hasName("putAll") and arg = 0
  or
  // java.util.ListIterator
  method.getDeclaringType() instanceof IteratorType and
  method.hasName(["add", "set"]) and
  arg = 0
  or
  // java.util.Collection
  method.(CollectionMethod).hasName(["add", "addAll"]) and
  // Refer to the last parameter to also cover List::add(int, E) and List::addAll(int, Collection)
  arg = method.getNumberOfParameters() - 1
  or
  // java.util.List
  // covered by Collection: add(int, E), addAll(int, Collection<? extends E>)
  method.(CollectionMethod).hasName("set") and arg = 1
  or
  // java.util.Vector
  method.(CollectionMethod).hasName(["addElement", "insertElementAt", "setElementAt"]) and arg = 0
  or
  // java.util.Stack
  method.(CollectionMethod).hasName("push") and arg = 0
  or
  // java.util.Queue
  method.(CollectionMethod).hasName("offer") and arg = 0
  or
  // java.util.Deque
  // covered by Stack: push(E)
  method.(CollectionMethod).hasName(["addFirst", "addLast", "offerFirst", "offerLast"]) and arg = 0
  or
  // java.util.concurrent.BlockingQueue
  // covered by Queue: offer(E, long, TimeUnit)
  method.(CollectionMethod).hasName("put") and arg = 0
  or
  // java.util.concurrent.TransferQueue
  method.(CollectionMethod).hasName(["transfer", "tryTransfer"]) and arg = 0
  or
  // java.util.concurrent.BlockingDeque
  // covered by Deque: offerFirst(E, long, TimeUnit), offerLast(E, long, TimeUnit)
  method.(CollectionMethod).hasName(["putFirst", "putLast"]) and arg = 0
  or
  // java.util.Dictionary
  method
      .getDeclaringType()
      .getSourceDeclaration()
      .getASourceSupertype*()
      .hasQualifiedName("java.util", "Dictionary") and
  method.hasName("put") and
  arg = 1
}

/**
 * Holds if `method` is a library method that returns tainted data if its
 * `arg`th argument is tainted.
 */
private predicate taintPreservingArgumentToMethod(Method method, int arg) {
  method.getDeclaringType().hasQualifiedName("java.util", "Collections") and
  (
    method
        .hasName([
            "checkedCollection", "checkedList", "checkedMap", "checkedNavigableMap",
            "checkedNavigableSet", "checkedSet", "checkedSortedMap", "checkedSortedSet",
            "enumeration", "list", "max", "min", "singleton", "singletonList",
            "synchronizedCollection", "synchronizedList", "synchronizedMap",
            "synchronizedNavigableMap", "synchronizedNavigableSet", "synchronizedSet",
            "synchronizedSortedMap", "synchronizedSortedSet", "unmodifiableCollection",
            "unmodifiableList", "unmodifiableMap", "unmodifiableNavigableMap",
            "unmodifiableNavigableSet", "unmodifiableSet", "unmodifiableSortedMap",
            "unmodifiableSortedSet"
          ]) and
    arg = 0
    or
    method.hasName(["nCopies", "singletonMap"]) and arg = 1
  )
  or
  method
      .getDeclaringType()
      .getSourceDeclaration()
      .hasQualifiedName("java.util", ["List", "Map", "Set"]) and
  method.hasName("copyOf") and
  arg = 0
  or
  method.getDeclaringType().getSourceDeclaration().hasQualifiedName("java.util", "Map") and
  (
    method.hasName("of") and
    arg = any(int i | i in [1 .. 10] | 2 * i - 1)
    or
    method.hasName("entry") and
    arg = 1
  )
  or
  method.getDeclaringType().hasQualifiedName("java.util", "Arrays") and
  (
    method.hasName(["copyOf", "copyOfRange", "spliterator", "stream"]) and
    arg = 0
  )
}

/**
 * Holds if `method` is a library method that returns tainted data if any
 * of its arguments are tainted.
 */
private predicate taintPreservingArgumentToMethod(Method method) {
  method.getDeclaringType().getSourceDeclaration().hasQualifiedName("java.util", ["Set", "List"]) and
  method.hasName("of")
  or
  method.getDeclaringType().getSourceDeclaration().hasQualifiedName("java.util", "Map") and
  method.hasName("ofEntries")
}

/**
 * Holds if `method` is a library method that writes tainted data to the
 * `output`th argument if the `input`th argument is tainted.
 */
private predicate taintPreservingArgToArg(Method method, int input, int output) {
  method.getDeclaringType().hasQualifiedName("java.util", "Collections") and
  (
    method.hasName(["copy", "fill"]) and
    input = 1 and
    output = 0
    or
    method.hasName("replaceAll") and input = 2 and output = 0
  )
  or
  method.getDeclaringType().hasQualifiedName("java.util", "Arrays") and
  (
    method.hasName("fill") and
    output = 0 and
    input = method.getNumberOfParameters() - 1
  )
}

private predicate argToQualifierStep(Expr tracked, Expr sink) {
  exists(Method m, int i, MethodAccess ma |
    taintPreservingArgumentToQualifier(m, i) and
    ma.getMethod() = m and
    tracked = ma.getArgument(i) and
    sink = ma.getQualifier()
  )
}

/** Access to a method that passes taint from an argument. */
private predicate argToMethodStep(Expr tracked, MethodAccess sink) {
  exists(Method m |
    m = sink.getMethod() and
    (
      exists(int i |
        taintPreservingArgumentToMethod(m, i) and
        tracked = sink.getArgument(i)
      )
      or
      m.getDeclaringType().hasQualifiedName("java.util", "Arrays") and
      m.hasName("asList") and
      tracked = sink.getAnArgument()
    )
  )
  or
  taintPreservingArgumentToMethod(sink.getMethod()) and
  tracked = sink.getAnArgument()
}

/**
 * Holds if `tracked` and `sink` are arguments to a method that transfers taint
 * between arguments.
 */
private predicate argToArgStep(Expr tracked, Expr sink) {
  exists(MethodAccess ma, Method method, int input, int output |
    ma.getMethod() = method and
    ma.getArgument(input) = tracked and
    ma.getArgument(output) = sink and
    (
      taintPreservingArgToArg(method, input, output)
      or
      method.getDeclaringType().hasQualifiedName("java.util", "Collections") and
      method.hasName("addAll") and
      input >= 1 and
      output = 0
    )
  )
}

/**
 * Holds if the step from `n1` to `n2` is either extracting a value from a
 * container, inserting a value into a container, or transforming one container
 * to another. This is restricted to cases where `n2` is the returned value of
 * a call.
 */
predicate containerReturnValueStep(Expr n1, Expr n2) {
  qualifierToMethodStep(n1, n2) or argToMethodStep(n1, n2)
}

/**
 * Holds if the step from `n1` to `n2` is either extracting a value from a
 * container, inserting a value into a container, or transforming one container
 * to another. This is restricted to cases where the value of `n2` is being modified.
 */
predicate containerUpdateStep(Expr n1, Expr n2) {
  qualifierToArgumentStep(n1, n2) or
  argToQualifierStep(n1, n2) or
  argToArgStep(n1, n2)
}

/**
 * Holds if the step from `n1` to `n2` is either extracting a value from a
 * container, inserting a value into a container, or transforming one container
 * to another.
 */
predicate containerStep(Expr n1, Expr n2) {
  containerReturnValueStep(n1, n2) or
  containerUpdateStep(n1, n2)
}

/**
 * Holds if the step from `node1` to `node2` stores a value in an array.
 * This covers array assignments and initializers as well as implicit array
 * creations for varargs.
 */
predicate arrayStoreStep(Node node1, Node node2) {
  exists(Argument arg |
    node1.asExpr() = arg and
    arg.isVararg() and
    node2.(ImplicitVarargsArray).getCall() = arg.getCall()
  )
  or
  node2.asExpr().(ArrayInit).getAnInit() = node1.asExpr()
  or
  exists(Assignment assign | assign.getSource() = node1.asExpr() |
    node2.(PostUpdateNode).getPreUpdateNode().asExpr() = assign.getDest().(ArrayAccess).getArray()
  )
}

private predicate enhancedForStmtStep(Node node1, Node node2, Type containerType) {
  exists(EnhancedForStmt for, Expr e, SsaExplicitUpdate v |
    for.getExpr() = e and
    node1.asExpr() = e and
    containerType = e.getType() and
    v.getDefiningExpr() = for.getVariable() and
    v.getAFirstUse() = node2.asExpr()
  )
}

/**
 * Holds if the step from `node1` to `node2` reads a value from an array.
 * This covers ordinary array reads as well as array iteration through enhanced
 * `for` statements.
 */
predicate arrayReadStep(Node node1, Node node2, Type elemType) {
  exists(ArrayAccess aa |
    aa.getArray() = node1.asExpr() and
    aa.getType() = elemType and
    node2.asExpr() = aa
  )
  or
  exists(Array arr |
    enhancedForStmtStep(node1, node2, arr) and
    arr.getComponentType() = elemType
  )
}

/**
 * Holds if the step from `node1` to `node2` reads a value from a collection.
 * This only covers iteration through enhanced `for` statements.
 */
predicate collectionReadStep(Node node1, Node node2) {
  enhancedForStmtStep(node1, node2, any(Type t | not t instanceof Array))
}
