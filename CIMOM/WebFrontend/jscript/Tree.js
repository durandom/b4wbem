// Tree.js
//
// Javascript expandable/collapsable tree class.
// Written by Jef Pearlman (jef@mit.edu)
// 
///////////////////////////////////////////////////////////////////////////////

// class Tree 
// {
//   public: 
//       // These functions can be used to interface with a tree. 
//     void TreeView(params);
//       // Constructs a TreeView. Params must be an object containing the
//       // following properties:
//       // id: UNIQUE id for the tree
//       // items: Nested array of strings and arrays determining the tree 
//       //        structure and content.
//       // x: Optional x position for tree.
//       // y: Optional y position for tree.
//     int getHeight();
//       // Returns the height of the tree, fully expanded.
//     int getWidth();
//       // Returns the width of the widest section of the tree, 
//       // fully expanded.
//     int getVisibleHeight();
//       // Returns the height of the visible tree.
//     int getVisibleWidth();
//       // Returns the width of the widest visible section of the tree. 
//     int getX();
//       // Returns the x position of the tree. 
//     int getY();
//       // Returns the y position of the tree.
//     Object getLayer();
//       // Returns the layer object enclosing the entire tree.
// }

// Define configuration
var prefix = "";

// Define global variables
var currNode;
var usergroupsnode;

function TreeNode(content, enclosing, id, depth, y)
     // Constructor for a TreeNode object, creates the appropriate layers
     // and sets the required properties.
{
  this.id = id;
  this.enclosing = enclosing;
  this.children = new Array;
  this.maxChild = 0;
  this.expanded = false;
  this.modified = false;
  this.getWidth = TreeNode_getWidth;
  this.getVisibleWidth = TreeNode_getVisibleWidth;
  this.getHeight = TreeNode_getHeight;
  this.getVisibleHeight = TreeNode_getVisibleHeight;
  this.layout = TreeNode_layout;
  this.relayout = TreeNode_relayout;
  this.childLayer = null;
  this.parent = this.enclosing.node;
  this.tree = this.parent.tree;
  this.depth = depth;
  this.loadDone = true;  // Only needed if no cim-request wanted at the second click on node
  this.expandNode = TreeNode_expand;
  this.name = '';

  // Write out the content for this item.
  document.write("<LAYER TOP="+y+" LEFT="+(this.depth*15)+" ID=Item"+this.id+">");
  document.write("<LAYER ID=Buttons WIDTH=14 HEIGHT=14>");
  document.write("<LAYER ID=Minus VISIBILITY=HIDE WIDTH=14 HEIGHT=14><IMG SRC=/WebFrontend/images/Tree_minus.gif WIDTH=14 HEIGHT=14></LAYER>");
  document.write("<LAYER ID=Plus WIDTH=14 VISIBILITY=HIDE HEIGHT=14><IMG SRC=/WebFrontend/images/Tree_plus.gif WIDTH=14 HEIGHT=14></LAYER>");
  document.write("<LAYER ID=Disabled VISIBILITY=INHERIT WIDTH=14 HEIGHT=14><IMG SRC=/WebFrontend/images/Tree_disabled.gif WIDTH=14 HEIGHT=14></LAYER>");
  document.write("</LAYER>"); // Buttons
  this.layer = this.enclosing.layers['Item'+this.id];
  this.layers = this.layer.layers;
  document.write("<LAYER ID=Content LEFT="+(this.layers['Buttons'].x+15)+">"+content+"</LAYER>");
  document.write("</LAYER>"); // Item

  // Move the buttons to the right position (centered vertically) and
  // capture the appropriate events.
  this.layers['Buttons'].moveTo(this.layers['Buttons'].x, this.layers['Content'].y+((this.layers['Content'].document.height-14)/2));
  this.layers['Buttons'].layers['Plus'].captureEvents(Event.MOUSEDOWN);
  this.layers['Buttons'].layers['Plus'].onmousedown=TreeNode_onmousedown_Plus;
  this.layers['Buttons'].layers['Plus'].node=this;
  this.layers['Buttons'].layers['Minus'].captureEvents(Event.MOUSEDOWN);
  this.layers['Buttons'].layers['Minus'].onmousedown=TreeNode_onmousedown_Minus;
  this.layers['Buttons'].layers['Minus'].node=this;

  // Note the height and width;
  this.height=this.layers['Content'].document.height;
  this.width=this.layers['Content'].document.width + 15 + (depth*15);

  // Register the node for later expanding
  // (As long as there are no nodenames given as parameter
  // we have to use regular expressions)
  var re;
  re = /\>Benutzer\</;
  if (re.test(content)) this.name = 'NODE-USER';
  re = /\>Paul.Administration\</;
  if (re.test(content)) this.name = 'NODE-PAULADMIN';
  re = /\>Gruppenrechte\</;
  if (re.test(content)) this.name = 'NODE-GROUPRIGHTS';
  re = /\>Dom.nen\</;
  if (re.test(content)) this.name = 'NODE-DOMAINS';
}

function Tree_build(node, items, depth, nexty)
     // Recursive function builds a tree, starting at the current node
     // using the items in items, starting at depth depth, where nexty
     // is where to locate the new layer to be placed correctly.
{
  //alert(node.id);
  var i;
  var nextyChild=0;

  if (node.tree.version >= 4)
    {
      // Create the layer for all the children.
      document.write("<LAYER TOP="+nexty+" VISIBILITY=HIDE ID=Children>");
      node.childLayer = node.enclosing.layers['Children'];
      node.childLayer.node = node;
    }
  else
    {
      // For Navigator 3.0, create a nested unordered list.
      document.write("<UL>");
    }
  for (i=0; i<items.length; i++)
    {
      if(typeof(items[i]) == "string")
	{
	  if (node.tree.version >= 4)
	    {
	      // Create a new node as the next child.
	      node.children[node.maxChild] = new TreeNode(items[i], node.childLayer, node.maxChild, depth, nextyChild);
	      nextyChild+=node.children[node.maxChild].height;
	    }
	  else
	    {
	      // Create a new item.
	      document.write("<LI>"+items[i]);
	    }
	  node.maxChild++;
	}
      else
	if (node.maxChild > 0)
	  {
	    // Build a new tree using the nested items array, placing it
	    // under the last child created.
	    if (node.tree.version >= 4)
	      {
		Tree_build(node.children[node.maxChild-1], items[i], depth+1, nextyChild);    
		nextyChild+=node.children[node.maxChild-1].getHeight()-node.children[node.maxChild-1].height;
		node.children[node.maxChild-1].layer.layers['Buttons'].layers['Disabled'].visibility="hide";
		node.children[node.maxChild-1].layer.layers['Buttons'].layers['Plus'].visibility="inherit";
	      }
	    else
	      Tree_build(node, items[i], depth+1, nextyChild);    
	  }
    }
  
  // End the layer or nested unordered list.
  if (node.tree.version >= 4)
    document.write("</LAYER>"); // childLayer
  else
    {
      document.write("</UL>");
    }

}

function TreeNode_onmousedown_Plus(e)
     // Handle a mouse down on a plus (expand).
{
  var node=this.node;
  //alert("depth: "+node.depth+" id: "+node.id+" parent.id: "+node.parent.id);

  // Use these cases to apply certain actions to the + and
  // - Buttons. Each of them obtains a certain node.depth, a node.id value
  // and a parent. So, identification is easy.

  if (node.name == 'NODE-USER') {
    location.href='/paul-menu?submenu=USER';
    return;
  } else if (node.name == 'NODE-GROUPRIGHTS') {
    location.href='/paul-menu?submenu=GROUPRIGHTS';
    return;
  } else if (node.name == 'NODE-DOMAINS') {
    location.href='/paul-menu?submenu=DOMAINS';
    return;
  }

  var oldHeight=node.getVisibleHeight();
  // Switch the buttons, set the current node expanded, and
  // relayout everything below it before before displaying the node.
  node.layers['Buttons'].layers['Minus'].visibility="inherit";
  node.layers['Buttons'].layers['Plus'].visibility="hide";
  node.expanded=true;
  node.parent.relayout(node.id,node.getVisibleHeight()-oldHeight);
  node.childLayer.visibility='inherit';
  return false;
}

function TreeNode_expand(node)
     // node.expandNode
{
  var node=node;
  var oldHeight=node.getVisibleHeight();
  // Switch the buttons, set the current node expanded, and
  // relayout everything below it before before displaying the node.
  node.layers['Buttons'].layers['Minus'].visibility="inherit";
  node.layers['Buttons'].layers['Plus'].visibility="hide";
  node.expanded=true;
  node.parent.relayout(node.id,node.getVisibleHeight()-oldHeight);
  node.childLayer.visibility='inherit';
  return false;
}

function expandNamedNode(nodename)
{
  var expandNode;
  // Identify node via loop
  var level1Nodes = paulTree.children;
  nodeloop:
  for (i=0; i<level1Nodes.length; i++) {
    if (level1Nodes[i].name == nodename) {
      var node = level1Nodes[i];
      var oldHeight=node.getVisibleHeight();
      node.layers['Buttons'].layers['Minus'].visibility="inherit";
      node.layers['Buttons'].layers['Plus'].visibility="hide";
      node.expanded=true;
      node.parent.relayout(node.id,node.getVisibleHeight()-oldHeight);
      node.childLayer.visibility='inherit';
      break nodeloop;
    }
    if (level1Nodes[i].children.length > 0) {
      var level2Nodes = level1Nodes[i].children;
      for (k=0; k<level2Nodes.length; k++) {
        if (level2Nodes[k].name == nodename) {
          // expand level1Node first
          var node = level1Nodes[i];
          var oldHeight=node.getVisibleHeight();
          node.layers['Buttons'].layers['Minus'].visibility="inherit";
          node.layers['Buttons'].layers['Plus'].visibility="hide";
          node.expanded=true;
          node.parent.relayout(node.id,node.getVisibleHeight()-oldHeight);
          node.childLayer.visibility='inherit';
          // expand level2Node next
          node = level2Nodes[k];
          oldHeight=node.getVisibleHeight();
          node.layers['Buttons'].layers['Minus'].visibility="inherit";
          node.layers['Buttons'].layers['Plus'].visibility="hide";
          node.expanded=true;
          node.parent.relayout(node.id,node.getVisibleHeight()-oldHeight);
          node.childLayer.visibility='inherit';
          break nodeloop;
        }
      }
    }
  }
  return false;
}


function TreeNode_onmousedown_Minus(e)
     // Handle a mouse down on a minus (collapse).
{
  var node=this.node;
  var oldHeight=node.getVisibleHeight();
  // Switch the buttons, set the current node collapsed, and
  // hide the node before relaying out everything below it.
  node.layers['Buttons'].layers['Plus'].visibility="inherit";
  node.layers['Buttons'].layers['Minus'].visibility="hide";
  node.expanded=false;
  node.childLayer.visibility='hide';
  node.parent.relayout(node.id,node.getVisibleHeight()-oldHeight);  
  return false;
}

function TreeNode_onmousedown_Content(e)
     // Handle a mouse down on a content layer
{
  // reset all untouched layers to bgcolor white, others to pink
  var layers1Root   = document.layers[0].layers[0].layers[0];
  var layers1Len    = layers1Root.layers.length;
  var re = /^Children/;
  for (var i = 0 ; i <layers1Len; i++) {
    if (re.test(layers1Root.layers[i].id)) {
      var layers2Root = layers1Root.layers[i];
      var layers2Len  = layers2Root.layers.length;
      for (var k = 0 ; k <layers2Len; k++) {
        if (re.test(layers2Root.layers[k].id)) {
          var layers3Root = layers2Root.layers[k];
          var layers3Len  = layers3Root.layers.length;
          for (var l = 0 ; l <layers3Len; l++) {
            if (re.test(layers3Root.layers[l].id)) {
            } else if (layers3Root.layers[l].layers['Content']) {
              if (layers3Root.layers[l].modified)
                layers3Root.layers[l].layers['Content'].bgColor="plum";
              else
                layers3Root.layers[l].layers['Content'].bgColor="white";
            }
          }
        } else if (layers2Root.layers[k].layers['Content']){
          if (layers2Root.layers[k].modified)
            layers2Root.layers[k].layers['Content'].bgColor="plum";
          else
            layers2Root.layers[k].layers['Content'].bgColor="white";
        }
      }
    } else if (layers1Root.layers[i].layers['Content']) {
      if (layers1Root.layers[i].modified)
        layers1Root.layers[i].layers['Content'].bgColor="plum";
      else
        layers1Root.layers[i].layers['Content'].bgColor="white";
    }
  }
  this.document.bgColor="lightgrey";
  currNode = this.parentLayer;
  return false;
}

function TreeNode_getHeight()
     // Get the Height of the current node and it's children.
{
  // Recursively add heights.
  var h=0, i;
  for (i = 0; i < this.maxChild; i++)
    h += this.children[i].getHeight();
  h += this.height;
  return h;
}

function TreeNode_getVisibleHeight()
     // Get the Height of the current node and it's visible children.
{
  // Recursively add heights. Only recurse if expanded.
  var h=0, i;
  if (this.expanded)
    for (i = 0; i < this.maxChild; i++)
      h += this.children[i].getVisibleHeight();
  h += this.height;
  return h;
}

function TreeNode_getWidth()
     // Get the max Width of the current node and it's children.
{
  // Find the max width by recursively comparing.
  var w=0, i;
  for (i=0; i<this.maxChild; i++)
    if (this.children[i].getWidth() > w)
      w = this.children[i].getWidth();
  if (this.width > w)
    return this.width;
  return w;
}

function TreeNode_getVisibleWidth()
     // Get the max Width of the current node and it's visible children.
{
  // Find the max width by recursively comparing. Only recurse if expanded.
  var w=0, i;
  if (this.expanded)
    for (i=0; i<this.maxChild; i++)
      if (this.children[i].getVisibleWidth() > w)
	w = this.children[i].getVisibleWidth();
  if (this.width > w)
    return this.width;
  return w;
}

function TreeView_getX()
     // Get the x location of the main tree layer.
{
  // Return the x property of the main layer.
  return document.layers[this.id+"Tree"].x;
}

function TreeView_getY()
     // Get the y location of the main tree layer.
{
  // Return the y property of the main layer.
  return document.layers[this.id+"Tree"].y;
}

function getLayer()
     // Get the main layer object.
{
  // Returnt he main layer.
  return document.layers[this.id+"Tree"];
}

function TreeNode_layout()
     // Layout the entire tree from scratch, recursively.
{
  var nexty=0, i;
  // Set the layer visible if expanded, hidden if not.
  if (this.expanded)
    this.childLayer.visibility="inherit";
  else
    if (this.childLayer != null)
      this.childLayer.visibility="hide";
  // If there is a child layer, move it to the appropriate position, and
  // move the children, laying them each out in turn.
  if (this.childLayer != null)
    {
      this.childLayer.moveTo(0, this.layer.y+this.height);
      for (i=0; i<this.maxChild; i++)
	{
	  this.children[i].layer.moveTo((this.depth+1)*15, nexty);
	  this.children[i].layout();
	  nexty+=this.children[i].height;
	}
    }
}

function TreeNode_relayout(id, movey)
{
  // Move all children physically below the current child number id of
  // the current node. Much faster than doing a layout() each time.

  // Move all children _after_ this child.

  for (id++;id<this.maxChild; id++)
    {
      this.children[id].layer.moveBy(0, movey);
      if (this.children[id].childLayer != null)
	this.children[id].childLayer.moveBy(0, movey);
    }
  // If there is a parent, move all of its children below this node,
  // recursively.
  if (this.parent != null)
    this.parent.relayout(this.id, movey);
}

//function Tree(param)
function Tree(param_id,param_items)
     // Instantiates a tree and displays it, using the items, id, and optional
     // x and y in param.
{
  // Set up member variables and functions. Also duplicate important TreeNode
  // member variables so this can serve as a TreeNode (vaguely like 
  // subclassing)
  this.version=eval(navigator.appVersion.charAt(0));
  //this.id = param.id;
  this.id = param_id;
  this.children = new Array;
  this.maxChild = 0;
  this.expanded = true;
  this.layout = TreeNode_layout;
  this.relayout = TreeNode_relayout;
  this.getX = TreeView_getX;
  this.getY = TreeView_getY;
  this.getWidth = TreeNode_getWidth;
  this.getVisibleWidth = TreeNode_getVisibleWidth;
  this.getHeight = TreeNode_getHeight;
  this.getVisibleHeight = TreeNode_getVisibleHeight;
  this.depth = -1;
  this.height = 0;
  this.width = 0;
  this.tree = this;
  //var items = eval(param.items);
  var items = eval(param_items);

  var left = "";
  var top = "";
  /*
  if (param.x != null && param.x != "")
    left += " LEFT="+param.x;
  if (param.y != null && param.y != "")
    top += " TOP="+param.y;
  */

  if (this.version >= 4)
    {
      // Create a surrounding layer to guage size and control the entire tree.
      // Also create a secondary internal layer so that the code can treat
      // the tree itself correctly as a node (must have an enclosing layer
      // and a children layer).
      document.write("<LAYER VISIBILITY=HIDE ID="+this.id+"Tree"+left+top+">");
      document.write("<LAYER ID=mainLayer>");
      this.enclosing = document.layers[this.id+"Tree"].layers['mainLayer'];
      this.layers = this.enclosing.layers;
      this.layer = this.enclosing;
      this.enclosing.node = this;
    } 

  Tree_build(this, items, 0, 0); // Build the tree.
  
  if (this.version >= 4)
    {
      // Finish output, record size;
      document.write("</LAYER></LAYER>");
      this.layout();

      // If you want to expand, you can do it here:
      //this.children[2].expandNode(this.children[2]);

      document.layers[this.id+"Tree"].visibility="inherit";
      // Add Background-color-functionality (Author: F.Fox)

      var layers1Root   = document.layers[0].layers[0].layers[0];
      var layers1Len    = layers1Root.layers.length;
      var re = /^Children/;
      for (var i = 0 ; i <layers1Len; i++) {
        if (re.test(layers1Root.layers[i].id)) {
          var layers2Root = layers1Root.layers[i];
          var layers2Len  = layers2Root.layers.length;
          for (var k = 0 ; k <layers2Len; k++) {
            if (re.test(layers2Root.layers[k].id)) {
              var layers3Root = layers2Root.layers[k];
              var layers3Len  = layers3Root.layers.length;
              for (var l = 0 ; l <layers3Len; l++) {
                if (re.test(layers3Root.layers[l].id)) {
                } else if (layers3Root.layers[l].layers['Content']) {
                  var currLayer = layers3Root.layers[l].layers['Content'];
                  currLayer.captureEvents(Event.MOUSEDOWN);
                  currLayer.onmousedown=TreeNode_onmousedown_Content;
                  currLayer.node=this;
                }
              } // end for-l-loop
            } else if (layers2Root.layers[k].layers['Content']){
              var isLink = false;
              if (k+1 < layers2Len) {
                if (!re.test(layers2Root.layers[k].id) && !re.test(layers2Root.layers[k+1].id)) {
                  isLink = true;
                }
              } else if (!re.test(layers2Root.layers[k].id)) {
                isLink = true;
              }
              if (isLink) {
                var currLayer = layers2Root.layers[k].layers['Content'];
                currLayer.captureEvents(Event.MOUSEDOWN);
                currLayer.onmousedown=TreeNode_onmousedown_Content;
                currLayer.node=this;
              }
            }
          } // end for-k-loop
        } else if (layers1Root.layers[i].layers['Content']) {
          var isLink = false;
          if (i+1 < layers1Len) {
            if (!re.test(layers1Root.layers[i].id) && !re.test(layers1Root.layers[i+1].id)) {
              isLink = true;
            }
          } else if (!re.test(layers1Root.layers[i].id)) {
            isLink = true;
          }
          if (isLink) {
            var currLayer = layers1Root.layers[i].layers['Content'];
            currLayer.captureEvents(Event.MOUSEDOWN);
            currLayer.onmousedown=TreeNode_onmousedown_Content;
            currLayer.node=this;
          }
        }
      } // end for-i-loop
    }
}




