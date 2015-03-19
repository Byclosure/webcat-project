class Blob

  def initialize(params={})
    @sha, @path, @repository = params[:sha], params[:path], params[:repository]
    @raw_blob = Gitlab::Git::Blob.find(@repository, @sha, @path)

    raise ArgumentError("Blob with sha: '#{@sha}' and path: '#{@path}' does not exist in the repository") unless @raw_blob
  end

  def raw_exists?
    !@raw_blob.nil?
  end

  def text?
    @raw_blob.text?
  end

  def empty?
    @raw_blob.empty?
  end

  def path
    @raw_blob.path
  end

  def name
    @raw_blob.name
  end

  def image?
    @raw_blob.image?
  end

  def size
    @raw_blob.size
  end

  def data
    @raw_blob.data
  end

  def language
    @raw_blob.language
  end

  def is_feature?
    name =~ /\.feature$/
  end

  def mime_type
    @raw_blob.mime_type
  end
end