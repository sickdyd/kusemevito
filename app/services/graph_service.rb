require 'rgl/adjacency'
require 'rgl/dot'

class GraphService
  attr_reader :graph

  # The API does not return the kind of resource, so we need to keep track of it ourselves
  RESOURCE_KIND_NAMESPACE = "Namespace"
  RESOURCE_KIND_DEPLOYMENT = "Deployment"
  RESOURCE_KIND_SERVICE = "Service"
  RESOURCE_KIND_POD = "Pod"

  def initialize
    @graph = RGL::DirectedAdjacencyGraph.new
    @client = KubernetesClientService.new

    build_k8s_graph
  end

  private

  def build_k8s_graph
    namespaces = @client.namespaces
    namespaces.each do |namespace|
      vertex(namespace, RESOURCE_KIND_NAMESPACE)

      deployments = @client.namespaced_deployments(name(namespace))
      deployments.each do |deployment|
        vertex(deployment, RESOURCE_KIND_DEPLOYMENT,uid(namespace))

        services = @client.namespaced_services(name(namespace), "app=#{name(deployment)}")
        services.each do |service|
          vertex(service, RESOURCE_KIND_SERVICE, uid(deployment))

          pods = @client.namespaced_pods(name(namespace), "app=#{name(deployment)}")
          pods.each do |pod|
            vertex(pod, RESOURCE_KIND_POD, uid(service))
          end
        end
      end
    end
  end

  private

  def uid(resource)
    resource["metadata"]["uid"]
  end

  def name(resource)
    resource["metadata"]["name"]
  end

  def vertex(resource, kind, parent_resource_uid=nil)
    graph.add_vertex(uid(resource))
    graph.set_vertex_options(uid(resource), vertex_options(resource, kind))

    graph.add_edge(parent_resource_uid, uid(resource)) if parent_resource_uid.present?
  end

  def vertex_options(resource, kind=nil)
    options = { label: name(resource), id: uid(resource) }
    
    if kind == RESOURCE_KIND_NAMESPACE
      options.merge!(namespace_vertex_options)
    elsif kind == RESOURCE_KIND_DEPLOYMENT
      options.merge!(deployment_vertex_options)
    elsif kind == RESOURCE_KIND_SERVICE
      options.merge!(service_vertex_options)
    end

    options
  end

  def namespace_vertex_options
    {
      shape: 'doublecircle',
      fontsize: 14
    }
  end

  def deployment_vertex_options
    {
      shape: 'box3d',
      fontsize: 14
    }
  end

  def service_vertex_options
    {
      shape: 'tab',
      fontsize: 14
    }
  end

  def pod_vertex_options
    {
      shape: 'ellipse',
      fontsize: 14
    }
  end
end

# # options for node declaration
# NODE_OPTS = [
#   'color', # default: black; node shape color
#   'colorscheme', # default: X11; scheme for interpreting color names
#   'comment', # any string (format-dependent)
#   'distortion', # default: 0.0; node distortion for shape=polygon
#   'fillcolor', # default: lightgrey/black; node fill color
#   'fixedsize', # default: false; label text has no affect on node size
#   'fontcolor', # default: black; KIND face color
#   'fontname', # default: Times-Roman; font family
#   'fontsize', # default: 14; point size of label
#   'group', # name of node's group
#   'height', # default: .5; height in inches
#   'id', # any string (user-defined output object tags)
#   'label', # default: node name; any string
#   'labelloc', # default: c; node label vertical alignment
#   'layer', # default: overlay range; all, id or id:id
#   'margin', # default: 0.11,0.55; space around label
#   'nojustify', # default: false; if true, justify to label, not node
#   'orientation', # default: 0.0; node rotation angle
#   'penwidth', # default: 1.0; width of pen for drawing boundaries, in points
#   'peripheries', # shape-dependent number of node boundaries
#   'regular', # default: false; force polygon to be regular
#   'samplepoints', # default 8 or 20; number vertices to convert circle or ellipse
#   'shape', # default: ellipse; node shape; see Section 2.1 and Appendix E
#   'shapefile', # external EPSF or SVG custom shape file
#   'sides', # default: 4; number of sides for shape=polygon
#   'skew', # default: 0.0; skewing of node for shape=polygon
#   'style', # graphics options, e.g. bold, dotted, filled; cf. Section 2.3
#   'target', # if URL is set, determines browser window for URL
#   'tooltip', # default: label, tooltip annotation for node
#   'URL', # URL associated with node (format-dependent)
#   'width', # default: .75; width in inches
# ].freeze

# ellipse: Elliptical shape.
# box: Rectangular shape.
# circle: Circular shape.
# triangle: Triangle shape.
# diamond: Diamond shape.
# parallelogram: Parallelogram shape.
# hexagon: Hexagon shape.
# invtriangle: Inverted triangle shape.
# invtrapezium: Inverted trapezium shape.
# invhouse: Inverted house shape.
# doublecircle: Double circle shape.
# doubleoctagon: Double octagon shape.
# note: Note shape.
# plaintext: Plain text shape.
